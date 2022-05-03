from audioop import mul
import codecs
import boto3
from botocore.exceptions import ClientError
import csv
import os
import json
import urllib.parse


# Headers
headers = ["id", "transaction_id",  "merchant", "mcc", "currency", "amount", "transaction_date", "card_id", "card_pan", "card_type"]

# Establish clients
s3 = boto3.client('s3')
sns_client = boto3.client('sns')
sqs_client = boto3.client('sqs')

# Variables retrieved from environ
SNS_TOPIC_ARN = os.environ['SNS_TOPIC_ARN']
PROCESSED_BUCKET = os.environ['PROCESSED_BUCKET']
SQS_QUEUE = os.environ['SQS_QUEUE']


# Get queue URL
queue = sqs_client.get_queue_url(QueueName=SQS_QUEUE)


def copy_and_delete_file(bucket, key):
    # Copy file to S3 bucket
    try:
        copy_file = {
            'Bucket': bucket,
            'Key': key
        }
        s3.copy_object(Bucket=PROCESSED_BUCKET, CopySource=copy_file, Key=key)
    except:
        print("An error has occurred with copying file to processed bucket.")
    else:
        # Delete file from original S3 bucket
        s3.delete_object(Bucket=bucket, Key=key)

# Process line
def process_line(line):
    line_array = line.split(",")
    
    for i in range(len(line_array)):
        line_array[i] = line_array[i].strip()
    
    return line_array

# Retrieve headers
def retrieve_header_index(line_array):
    indexes = {}
    for column in line_array:
        for header in headers:
            if column == header:
                indexes[column] = line_array.index(column)
    
    return indexes

# Helper function to convert scientific notation to string
def convert_to_string(value):
    value_array = value.split("+")

    # Create multiplier
    num_of_zero = int(value_array[1])
    multiplier = "1"
    for i in range(num_of_zero):
        multiplier += "0"
        i += 1
    multiplier = int(multiplier)


    # Convert string to decimal
    decimal_string = value_array[0]
    decimal = float(decimal_string[0:len(decimal_string)-1])

    number = int(decimal * multiplier)

    return str(number)


# To process users
def user_processing(bucket, key):
    # Process the file and send rows to SQS
    try:
        response = s3.get_object(Bucket=bucket, Key=key)

        data = response['Body'].read().decode('utf-8').splitlines()
        records = csv.reader(data, delimiter=",", skipinitialspace=True)

        
        # To retrieve the correct headers and its index
        file_headers = next(records)
        headers = {}

        # Strip whitespace from headers
        for i in range(len(file_headers)):
            headers[file_headers[i].strip()] = i

        
        for row in records:
            print(row)

            # Create return dict
            return_obj = {}

            for header in headers:
                value = row[headers[header]].strip()
                return_obj[header] = value


            # Send message to queue
            response = sqs_client.send_message(
                        QueueUrl=queue['QueueUrl'],
                        MessageBody= json.dumps(return_obj),
                        MessageGroupId='user'
                        )
    except Exception as e:
        print(e)



# To process transactions
def transaction_processing(bucket, key, headers):

    # Process the file and send rows to SQS
    try:
        response = s3.get_object(Bucket=bucket, Key=key)
        
        data = response['Body'].read().decode('utf-8').splitlines()
        records = csv.reader(data, delimiter=",", skipinitialspace=True)

        # To retrieve the correct headers and its index
        file_headers = next(records)
        print(file_headers)
        # Strip whitespace from headers
        for i in range(len(file_headers)):
            file_headers[i] = file_headers[i].strip()

        headers = retrieve_header_index(file_headers)
        print(headers)

        for row in records:
            print(row)

            # Create return dict
            return_obj = {}

            for header in headers:

                value = row[headers[header]].strip()

                if ("E+" in value):
                    # Convert scientific notation to string
                    value = convert_to_string(value)

                return_obj[header] = value
            
            # Publish message to SNS
            response = sns_client.publish(
                TargetArn = SNS_TOPIC_ARN,
                Message = json.dumps({
                            'default': json.dumps(return_obj)
                        }),
                Subject = 'Transaction Data',
                MessageStructure = 'json',
                MessageGroupId='Transaction'
            )
            print(response)

    except Exception as e:
        print(e)
        


# Main function
def lambda_handler(event, context):
    
    # Get the object from the event and show its content type
    bucket = event['Records'][0]['s3']['bucket']['name']
    key = urllib.parse.unquote_plus(event['Records'][0]['s3']['object']['key'], encoding='utf-8')

    # Retrieve name of the file without .csv extension
    name_arr = key.split(".")
    name = name_arr[0].lower()

    try:
        if "user" in name:
            user_processing(bucket=bucket, key=key)
            copy_and_delete_file(bucket=bucket, key=key)
        else:
            transaction_processing(bucket=bucket, key=key, headers={})
            copy_and_delete_file(bucket=bucket, key=key)
    except Exception as e:
        print(e)