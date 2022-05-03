import paramiko
import logging
import boto3
import json
import os
import csv
from botocore.exceptions import ClientError
from datetime import datetime

logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Get AWS Secret Manager Secret ARN from Lambda environment variable
# Which is provided by Terraform when creating the Lambda function
secret_arn = os.environ['SECRET_ARN']
secret_mgr_client = boto3.client('secretsmanager')
sftp_secret_str = secret_mgr_client.get_secret_value(SecretId=secret_arn)
sftp_credentials = json.loads(sftp_secret_str['SecretString'])

host = sftp_credentials['host']
port = int(sftp_credentials['port'])
username = sftp_credentials['username']
password = sftp_credentials['password']

transport = paramiko.Transport((host, port))
transport.connect(username=username, password=password)
sftp = paramiko.SFTPClient.from_transport(transport)

s3_client = boto3.resource('s3')
lsd_bucket = 'itsag1t5-exavault-lsd'

# Getting the last spend date from the S3 bucket
scanned_spend_dates = []
scan_filename = 'last_spend_date.txt'
try:
    file_obj = s3_client.Object(lsd_bucket, scan_filename).get()
    lsd_file_content = file_obj['Body'].read().decode('utf-8')
    for line in lsd_file_content.split('\n'):
        scanned_spend_dates.append(line)
    logger.info(f'Scanned spend dates: {scanned_spend_dates}')
except ClientError as e:
    if e.response['Error']['Code'] == "NoSuchKey":
        logger.info("No last spend date file found in S3 bucket")
    else:
        raise

# Getting the last user date from the S3 bucket
scanned_user_dates = []
scan_filename = 'last_user_date.txt'
try:
    file_obj = s3_client.Object(lsd_bucket, scan_filename).get()
    lsd_file_content = file_obj['Body'].read().decode('utf-8')
    for line in lsd_file_content.split('\n'):
        scanned_user_dates.append(line)
    logger.info(f'Scanned user dates: {scanned_user_dates}')
except ClientError as e:
    if e.response['Error']['Code'] == "NoSuchKey":
        logger.info("No last user date file found in S3 bucket")
    else:
        raise


def upload_to_s3(s3_bucket, file_name, file_path):
    try:
        client = boto3.client('s3')
        client.upload_file(file_path, s3_bucket, file_name)
    except ClientError as e:
        logging.error(e)
        return False
    return True


def get_unscanned_dir(scanned_dates, dir_name):
    dir_scan = sftp.listdir(dir_name)

    unscanned_dates = set(dir_scan) - set(scanned_dates)
    unscanned_dates = list(unscanned_dates)
    unscanned_dates.sort()

    if len(unscanned_dates) > 0:
        return unscanned_dates[0]


def download_file(current_dir, latest_folder):
    tmp_raw_dir = '/tmp/raw'

    if not os.path.exists(tmp_raw_dir):
        os.makedirs(tmp_raw_dir)

    saveAs_filename = f'{current_dir}_{latest_folder}.csv'
    current_dir = f'{current_dir}/{latest_folder}'
    all_files = sftp.listdir(current_dir)

    for file in all_files:
        remote_file = f'{current_dir}/{file}'
        tmp_file_path = f'{tmp_raw_dir}/{saveAs_filename}'
        sftp.get(remote_file, tmp_file_path)


def file_spliter_n_upload(raw_dir, staging_dir, staging_bucket):
    if not os.path.exists(staging_dir):
        os.makedirs(staging_dir)

    raw_listdir = os.listdir(raw_dir)
    for file in raw_listdir:
        filepath = f'{raw_dir}/{file}'
        with open(filepath) as f:
            reader = csv.reader(f)
            header = next(reader)
            data = [row for row in reader]

            chunks = 20000
            for i in range(0, len(data), chunks):
                data_chunk = data[i:i+chunks]
                new_filename = f'{file.split(".")[0]}_{i}_to_{i+chunks}.csv'

                new_filepath = f'{staging_dir}/{new_filename}'
                with open(new_filepath, 'w') as f:
                    writer = csv.writer(f)
                    writer.writerow(header)
                    writer.writerows(data_chunk)

                if upload_to_s3(staging_bucket, new_filename, new_filepath):
                    logger.info(
                        f'Successfully uploaded {new_filename} to S3 bucket')
                    os.remove(new_filepath)
                else:
                    logger.error(
                        f'Failed to upload {new_filename} to S3 bucket')

        # After splitting the file, delete the raw file
        os.remove(filepath)


def handler(event, context):
    staging_bucket = 'itsag1t5-sftp-staging'

    # Check users folder
    latest_user_folder = get_unscanned_dir(scanned_user_dates, 'users')
    if latest_user_folder != None:
        download_file('users', latest_user_folder)
        scanned_user_dates.append(latest_user_folder)

    latest_spend_folder = get_unscanned_dir(scanned_spend_dates, 'spend')
    if latest_spend_folder != None:
        download_file('spend', latest_spend_folder)
        scanned_spend_dates.append(latest_spend_folder)

    tmp_staging_dir = '/tmp/staging'
    tmp_raw_dir = '/tmp/raw'
    file_spliter_n_upload(tmp_raw_dir, tmp_staging_dir, staging_bucket)

    # Save the last scanned dates to S3 bucket
    lsd_bucket = 'itsag1t5-exavault-lsd'
    last_spend_date_file = '/tmp/last_spend_date.txt'

    with open(last_spend_date_file, 'w') as f:
        for date in scanned_spend_dates:
            f.write(f'{date}\n')

    if upload_to_s3(lsd_bucket, 'last_spend_date.txt', last_spend_date_file):
        logger.info("Successfully uploaded last spend date file to S3 bucket")
    else:
        logger.error("Failed to upload last spend date file to S3 bucket")

    last_user_date_file = '/tmp/last_user_date.txt'

    with open(last_user_date_file, 'w') as f:
        for date in scanned_user_dates:
            f.write(f'{date}\n')

    if upload_to_s3(lsd_bucket, 'last_user_date.txt', last_user_date_file):
        logger.info("Successfully uploaded last user date file to S3 bucket")
    else:
        logger.error("Failed to upload last user date file to S3 bucket")

    # Remove file in tmp
    for filename in os.listdir('/tmp'):
        filepath = f'/tmp/{filename}'
        if os.path.isfile(filepath):
            os.remove(filepath)

    return {
        'statusCode': 200,
        'body': json.dumps({
            'lsd': ''
        })
    }
