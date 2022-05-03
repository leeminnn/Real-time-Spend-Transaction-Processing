import requests

result = requests.get(
    url='https://cdn.jsdelivr.net/gh/fawazahmed0/currency-api@1/latest/currencies/usd/sgd.json').json()

rate_of_exchange = result['sgd']
