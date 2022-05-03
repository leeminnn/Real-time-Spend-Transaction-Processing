import exchange_rate
excludeList = [6051, 9399, 6540]


def process_freedom(id, transaction_id, merchant, mcc, currency, amount, transaction_date, card_id, card_pan, card_type):
    reward_type = 'cashback'
    earn = 0
    amount = float(amount)
    value = 0

    if currency == "SGD" and amount > 2000:
        value = 3
        earn += amount*0.03
    elif currency == "SGD" and amount > 500:
        value = 1
        earn += amount*0.01
    elif currency == "SGD" and amount <= 500:
        value = 0.5
        earn += amount*0.005
    elif currency == "USD" and amount <= 500:
        value = 0.5
        earn += (exchange_rate.rate_of_exchange * amount) * 0.005

    remarks = f'Get {value}% in {reward_type}'
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
    # print(result)

    return result
