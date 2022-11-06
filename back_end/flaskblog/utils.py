from math import sqrt

def distance(lat1, long1, lat2, long2):
    lat3 = lat1 / 364000 # feet per degree of latitude
    lat4 = lat2 / 364000 
    long3 = long1 / 288200 # feet per degree of longitude
    long4 = long2 / 288200 # feet per degree of longitude
    return abs(sqrt(((long4 - long3) ** 2) + ((lat4 - lat3) ** 2)))
