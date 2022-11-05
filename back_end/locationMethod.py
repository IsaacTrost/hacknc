from flask import Flask
from flask import request
import requests



def getLocation():
    url = 'http://freegeoip.net/json/{}'.format(request.remote_addr)
    r = requests.get(url)
    j = json.loads(r.text)
    city = j['city']

    print(city)


