
'''
Script to populate localhost:8080 server with test data for demos.

Row key format:
#VENDOR_RANGE   #TIME_RANGE         #SUFFIX_RANGE
#[10000-99999]  #[YYYYMMDDHHmmSS]   #[4 char suffix hash]        
e.g. #12411#20220826102243#5123

For every row key, we append

To run: 
1) Make sure localhost:8080 backend server is up. 
2) python3 populate_db.py
'''

import requests
from datetime import datetime
from random import randrange, randint

URL = 'http://127.0.0.1:8080/api'

# Range to populate vendor IDs with.
VENDOR_RANGE = (10000, 99999)
# Range to populate suffix hashes with.
SUFFIX_RANGE = (1000, 9999)
# Aug 26, 2021 to August 8, 2022 in epoch seconds
TIME_RANGE = (1630000000, 1660000000)
# Candidate locations to choose from.
LOCATIONS = (
    'Louisville', 'Philadelphia', 'Dallas', 'Ontario', 'Rockford', 'Hamilton', 'Miami', 'New York', 'New Jersey', 'Mountain View'
)
# Final location keyword.
LOCATION_FINAL = 'DELIVERED'


def postURL(endpoint, body={}):
    print(URL+endpoint)
    x = requests.post(URL+endpoint, json=body)
    print(x)
    return x


def generateSuffix():
    # Generate a random suffix within suffix range.
    return randint(*SUFFIX_RANGE)


def generateLocation():
    # Select a random location from the location array.
    return LOCATIONS[randrange(len(LOCATIONS))]


def generateDelivered():
    # Generate either DELIVERED or an additional location with 50% probability each.
    if randrange(2) == 1:
        return LOCATION_FINAL
    else:
        return generateLocation()


def generateLocations(maxLocs=7):
    # Generate an array of locations (including DELIVERED)
    return [generateLocation() for i in range(randrange(maxLocs))] + [generateDelivered()]


def generateTimestamp():
    # Generate a random row-key-format timestamp within time range.
    return datetime.fromtimestamp(
        randint(*TIME_RANGE)).strftime('%Y%m%d%H%M%S')


def createAndPopulateRow(rowkey, locations):
    # Create a new row with rowkey and populate it with an array of locations.
    postURL('/create', {
        'packageId': rowkey,
        'packageLocation': locations[0]
    })
    # TODO: Add custom timestamps for each location for a more realistic demo.
    [postURL('/update', {
        'packageId': rowkey,
        'packageLocation': loc
    }) for loc in locations[1:]]


def main():
    # Clear old test data.
    postURL('/test/clear')

    # Generate packages for each vendor within vendor range.
    for vendor in range(*VENDOR_RANGE):
        # For each vendor, generate up to n rows.
        for i in range(randrange(10)):
            # Create row key and generate locations.
            rowkey = str(vendor) + generateTimestamp() + str(generateSuffix())
            locations = generateLocations()

            # Call backend server to create and populate BigTable rows.
            createAndPopulateRow(rowkey, locations)


if __name__ == '__main__':
    main()
