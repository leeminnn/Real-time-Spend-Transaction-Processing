excludeList = [6051, 9399, 6540]
onlineShop = ['Amazon.sg', 'Aliexpress', 'Carousell', 'EzBuy', 'Lazada',
              'RedMart (via Lazada)', 'Qoo10.sg', 'Shopee', 'Taobao (PC Browser)', 'Taobao (App)']


def process_shopping(id, transaction_id, merchant, mcc, currency, amount, transaction_date, card_id, card_pan, card_type):
    reward_type = 'points'
    earn = 0
    amount = float(amount)
    value = 0

    if merchant in onlineShop:
        value = 10
        earn += amount*10
    elif (mcc != '') and int(mcc) >= 5600 and int(mcc) <= 7299:
        value = 4
        earn += amount*4
    elif(mcc != '') and int(mcc) not in excludeList:
        value = 1
        earn += amount

    remarks = f'Get {value}points/SGD in {reward_type}'

    result = {
        'id': id,
        'transaction_id': transaction_id,
        'merchant': merchant,
        'mcc': mcc,
        "currency": currency,
        "amount": float(amount),
        "transaction_date": transaction_date,
        "card_id": card_id,
        "card_pan": card_pan,
        "card_type": card_type,
        'reward_type': reward_type,
        'value': earn,
        'remarks': remarks
    }

    return result
