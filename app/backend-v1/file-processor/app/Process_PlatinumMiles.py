import exchange_rate


def process_platinum_miles(id, transaction_id, merchant, mcc, currency, amount, transaction_date, card_id, card_pan, card_type):
    reward_type = 'miles'
    earn = 0
    amount = float(amount)
    value = 0

    if currency != "SGD" and ((mcc != '') and (int(mcc) == 7011)):
        value = 6
        earn += (exchange_rate.rate_of_exchange * amount) * 6
    elif currency == "SGD" and ((mcc != '') and (int(mcc) > 3499) and (int(mcc) < 4000)):
        value = 3
        earn += amount*3
    elif currency != "SGD":
        value = 3
        earn += (exchange_rate.rate_of_exchange * amount) * 3
    elif currency == "SGD":
        value = 1.4
        earn += amount*1.4

    remarks = f'Get {value}miles/SGD in {reward_type}'

    remarks = f'Get {value}miles/SGD in {reward_type}'
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
