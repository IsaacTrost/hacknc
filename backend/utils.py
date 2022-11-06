from math import sqrt

GRID_SIZE = 200


def distance(lat1, long1, lat2, long2):
    lat3 = lat1 / 364000  # feet per degree of latitude
    lat4 = lat2 / 364000
    long3 = long1 / 288200  # feet per degree of longitude
    long4 = long2 / 288200
    return abs(sqrt(((long4 - long3) ** 2) + ((lat4 - lat3) ** 2)))


def insideGrid(user_lat, user_long, grid_lat, grid_long):
    # user lat and long in feet
    user_lat_feet = (user_lat / 364000)
    user_long_feet = (user_long / 288200)

    # grid lat and long in feet
    grid_lat_feet = (grid_lat / 364000)
    grid_long_feet = (grid_long / 288200)

    # check if user is within dimensions of grid
    if abs(user_lat_feet - grid_lat_feet) < GRID_SIZE / 2 and abs(user_long_feet - grid_long_feet) < GRID_SIZE / 2:
        return True
    return False
