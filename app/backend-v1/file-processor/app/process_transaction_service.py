from fastapi import FastAPI, Request
import Process_Freedom
import Process_PlatinumMiles
import Process_PremiumMiles
import Process_Shopping
import boto_service

app = FastAPI()


@app.post("/process_transaction")
async def getInformation(info: Request):
    req_info = await info.json()
    processed_row = ''
    if req_info['card_type'] == 'scis_premiummiles':
        processed_row = Process_PremiumMiles.process_premium_miles(
            req_info['id'], req_info['transaction_id'], req_info['merchant'], req_info['mcc'], req_info['currency'], req_info['amount'], req_info['transaction_date'], req_info['card_id'], req_info['card_pan'], req_info['card_type'])
    elif req_info['card_type'] == 'scis_shopping':
        processed_row = Process_Shopping.process_shopping(
            req_info['id'], req_info['transaction_id'], req_info['merchant'], req_info['mcc'], req_info['currency'], req_info['amount'], req_info['transaction_date'], req_info['card_id'], req_info['card_pan'], req_info['card_type'])
    elif req_info['card_type'] == 'scis_platinummiles':
        processed_row = Process_PlatinumMiles.process_platinum_miles(
            req_info['id'], req_info['transaction_id'], req_info['merchant'], req_info['mcc'], req_info['currency'], req_info['amount'], req_info['transaction_date'], req_info['card_id'], req_info['card_pan'], req_info['card_type'])
    elif req_info['card_type'] == 'scis_freedom':
        processed_row = Process_Freedom.process_freedom(
            req_info['id'], req_info['transaction_id'], req_info['merchant'], req_info['mcc'], req_info['currency'], req_info['amount'], req_info['transaction_date'], req_info['card_id'], req_info['card_pan'], req_info['card_type'])

    # boto_service.mysqlconnect(processed_row)

    return "Success"


# python -m uvicorn process_transaction_service:app --reload
