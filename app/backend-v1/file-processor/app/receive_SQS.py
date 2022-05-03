import boto3
import Process_Freedom
import Process_PlatinumMiles
import Process_PremiumMiles
import Process_Shopping
import boto_service
import os
import json
from dotenv import load_dotenv
from multiprocessing import Pool
load_dotenv()

# set up client
sqs_client = boto3.client(
    "sqs",
    region_name=os.getenv("region_name"),
    aws_access_key_id=os.getenv("aws_access_key_id"),
    aws_secret_access_key=os.getenv("aws_secret_access_key")
)


def delete_message(sqs_client, receipt_handle):
    response = sqs_client.delete_message_batch(
        QueueUrl="queue-url",
        Entries=receipt_handle,
    )


def receive_message(sqs_client):
    response = sqs_client.receive_message(
        QueueUrl="queue-url",
        MaxNumberOfMessages=10,
        WaitTimeSeconds=20
    )

    print(f"Number of messages received: {len(response.get('Messages', []))}")

    messages = []
    values = []
    for message in response.get("Messages", []):
        params = eval(json.loads(message["Body"])['Message'])
        processed_row = ''
        print(params)
        if "-" in params['card_pan']:
            params['card_pan'] = params['card_pan'].replace("-", "")

        if params["card_type"] == 'scis_premiummiles':
            processed_row = Process_PremiumMiles.process_premium_miles(
                params["id"], params["transaction_id"], params['merchant'], params['mcc'], params['currency'], params['amount'], params['transaction_date'], params['card_id'], params['card_pan'], params['card_type'])
        elif params["card_type"] == 'scis_shopping':
            processed_row = Process_Shopping.process_shopping(
                params["id"], params["transaction_id"], params['merchant'], params['mcc'], params['currency'], params['amount'], params['transaction_date'], params['card_id'], params['card_pan'], params['card_type'])
        elif params["card_type"] == 'scis_platinummiles':
            processed_row = Process_PlatinumMiles.process_platinum_miles(
                params["id"], params["transaction_id"], params['merchant'], params['mcc'], params['currency'], params['amount'], params['transaction_date'], params['card_id'], params['card_pan'], params['card_type'])
        elif params["card_type"] == 'scis_freedom':
            processed_row = Process_Freedom.process_freedom(
                params["id"], params["transaction_id"], params['merchant'], params['mcc'], params['currency'], params['amount'], params['transaction_date'], params['card_id'], params['card_pan'], params['card_type'])

        # write rows to RDS
        values.append(processed_row)

        messages.append(
            {"Id": message["MessageId"], "ReceiptHandle": message["ReceiptHandle"]})

    p = Pool(processes=10)
    result = p.map(boto_service.mysqlconnect, values)
    p.close()
    if len(messages) != 0:
        delete_message(sqs_client, messages)


while True:
    try:
        response = sqs_client.get_queue_attributes(
            QueueUrl="queue-url",
            AttributeNames=['ApproximateNumberOfMessages']
        )

        print(response['Attributes']['ApproximateNumberOfMessages'])
        if int(response['Attributes']['ApproximateNumberOfMessages']) != 0:
            continue
        print("running")
        receive_message(sqs_client)
    except Exception as e:
        print(e)
        print("THERE IS AN ERROR")
    except:
        print("THERE IS AN ERROR")
