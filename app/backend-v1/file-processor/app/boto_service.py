import pymysql
import boto3
import os
import json
from dotenv import load_dotenv
from botocore.exceptions import ClientError
load_dotenv()


deploy_env = os.getenv("deploy_env")
client = boto3.client('secretsmanager', region_name=os.getenv("region_name"))

if deploy_env == 'dev':
    client = boto3.client('secretsmanager',
                        region_name=os.getenv("region_name"),
                        aws_access_key_id=os.getenv("aws_access_key_id"),
                        aws_secret_access_key=os.getenv("aws_secret_access_key")
                    )

response = client.get_secret_value(
    SecretId=os.getenv("secret_id")
)

database_secrets = json.loads(response['SecretString'])

dbhost = database_secrets['host']
dbuser = database_secrets['username']
dbpassword = database_secrets['password']
db=database_secrets['dbname']

def mysqlconnect(data):
    conn = pymysql.connect(
        host=dbhost,
        user=dbuser,
        password=dbpassword,
        db=db,
    )

    cur = conn.cursor()

    # Select query
    try:
        cur.execute(
        """SELECT userId FROM itsag1t5Ascenda.UserCard WHERE cardId=%s""", (data['card_id']))
        res = cur.fetchall()
        user_id = res[0][0]
        print(user_id)
        cur.execute(
        """SELECT * FROM itsag1t5Ascenda.Spending WHERE id=%s""", (data['id']))
        res = cur.fetchall()
        print(res)

        if len(res) == 0:
            cur.execute("""INSERT INTO itsag1t5Ascenda.Spending(`id`, `transactionId`, `merchant`, `mcc`, `currency`, `amount`, `transactionDate`, `cardId`) VALUES (%s, %s, %s, %s, %s, %s, %s, %s)""",
                        (data['id'], data['transaction_id'], data['merchant'], data['mcc'], data['currency'], data['amount'], data['transaction_date'], data['card_id']))
            conn.commit()

        cur.execute("""INSERT INTO itsag1t5Ascenda.RewardHistory(`spendingID`, `rewardType`, `value`, `remarks`) VALUES (%s, %s, %s, %s)""",
                (data['id'], data['reward_type'], data['value'], data['remarks']))
        conn.commit()

        cur.execute(
        """SELECT * FROM itsag1t5Ascenda.UserRewardBalance WHERE userId=%s""", (user_id))
        res = cur.fetchall()
        print(res)

        if len(res) == 0:
            cur.execute("""INSERT INTO itsag1t5Ascenda.UserRewardBalance(`userId`, `rewardType`, `balance`) VALUES (%s, %s, %s)""",
                        (user_id, data['reward_type'], data['value']))
            conn.commit()
        else:
            cur.execute(""" UPDATE itsag1t5Ascenda.UserRewardBalance SET balance = balance + %s WHERE  userId = %s and rewardType = %s""",
                        ( data['value'], user_id, data['reward_type']))
            conn.commit()
       

    except Exception as e:
        print(e)

    # To close the connection
    cur.close()