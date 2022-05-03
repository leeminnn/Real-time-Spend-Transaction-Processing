from datetime import datetime, time, timedelta
from uuid import UUID
import boto3
from boto3.dynamodb.conditions import Key, Attr
from fastapi import FastAPI, Request, File, UploadFile, Body
from pydantic import BaseModel
from fastapi.middleware.cors import CORSMiddleware
import os
import uuid
from dotenv import load_dotenv

load_dotenv()

origins = [*]


dynamodb = boto3.resource('dynamodb')

table = dynamodb.Table('itsag1t5_campaigns')


app = FastAPI()

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"]
)

# # Creating S3 Resource From the Session.
s3 = boto3.resource('s3')

bucket = 'name-of-bucket'


class Item(BaseModel):
    card: str
    reward: str
    merchant: str
    min: int | float
    rate: int | float
    startDate: datetime
    endDate: datetime
    imageURL: str
    description: str


@app.post("/campaign/new")
def getInformation(item: Item):
    myuuid = uuid.uuid4()

    response = table.put_item(Item={
        'id': str(myuuid),
        'card': item.card,
        'reward': item.reward,
        'merchant': item.merchant,
        'min': item.min,
        'rate': item.rate,
        'startDate': str(item.startDate),
        'endDate': str(item.endDate),
        'imageURL': item.imageURL,
        'description': item.description
    })

    return (200, response)


@app.post("/campaign/uploadfile")
async def create_upload_file(file: UploadFile = File(...)):
    s3.Bucket(bucket).put_object(Key=file.filename,
                                 Body=file.file, ACL='public-read')
    linkURL = 'https://' + bucket + '.s3.amazonaws.com/' + file.filename
    return(linkURL)


@app.get("/campaign/getall")
def get_all_campaigns():
    response = table.scan()
    return response['Items']


@app.get("/campaign/healthcheck")
def healthCheck():
    return "Service is Healthy"


# run the file
# python -m uvicorn admin_campaign:app --reload
