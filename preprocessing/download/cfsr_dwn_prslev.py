from os import truncate, wait
from time import sleep
from requests.exceptions import ChunkedEncodingError
import rdams_client as rc
from rdams_helper import *
import sys


passwd = ""
email = 'mckynde@gmail.com'
dsnum = 'ds093.0'
startdate = '198105310000'
enddate = '198106020600'
oformat = "WMO_GRIB2"
product = "6-hour Forecast"
grid =  "720:361:90N:0E:90S:359.5E:0.5:0.5"    #"0.5-deg x 0.5-deg from 0E to 359.5E and 90N to 90S (720 x 361 Longitude/Latitude)"
filename = "cfsr_prs_"+startdate+"-"+enddate+oformat
params = ['PRES',  # Pressure
          'PRMSL',   # Pressure reduced to MSL
          'R H',     #  Relative humidity
          'SPF H',   # Specific humidity
          'TMP',     #  Temperature
          'U GRD',  # u-component of wind
          'V GRD',   # v-component of wind
          'SOILW',   # Volumetric soil moisture content
          'WEASD',   # Water equivalent of accumulated snow depth
          'HGT',     # Geopotential height
          'ICEC',    # Ice cover
          'LAND'    # Land cover (0=sea, 1=land)
          ]

levs_isb = {
    'ISBL':['1000' ,      #Isobaric surface
            '975' ,       #  Isobaric surface
            '950' ,       #  Isobaric surface
            '925' ,       #  Isobaric surface
            '900' ,       #  Isobaric surface
            '875' ,
            '850' ,       #  Isobaric surface
            '825' ,
            '800' ,       #  Isobaric surface
            '775' ,
            '750' ,       #  Isobaric surface
            '700' ,       #  Isobaric surface
            '650' ,       #  Isobaric surface
            '600' ,       #  Isobaric surface
            '550' ,       #  Isobaric surface
            '500' ,       #  Isobaric surface
            '450' ,       #  Isobaric surface
            '400' ,       #  Isobaric surface
            '350' ,       #  Isobaric surface
            '300' ,       #  Isobaric surface
            '250' ,       #  Isobaric surface
            '225' ,
            '200' ,       #  Isobaric surface
            '175' ,
            '150' ,       #  Isobaric surface
            '125' ,
            '100' ,       #  Isobaric surface
            '70' ,       #  Isobaric surface
            '50' ,       #  Isobaric surface
            '30' ,       #  Isobaric surface
            '20' ,       #  Isobaric surface
            '10' ,       #  Isobaric surface
            '7',          #  Isobaric surface
            '5',          #  Isobaric surface
            '3',          #  Isobaric surface
            '2',          #  Isobaric surface
            '1',          #  Isobaric surface
            ],
        'SFC':['0'],       #  Ground or water surface
        'MSL':['0'],       #  Mean sea level
        'SPDL':['0,30'],      # Layer between two levels at specified pressure differences from ground to level
        'GPML':['1829',       #  Specified altitude above mean sea level
            '2743',       #  Specified altitude above mean sea level
            '3658',       #  Specified altitude above mean sea level
            '4572'],       #  Specified altitude above mean sea level
        'DBLL':['0.1,0' ,     # Layer between two depths below land surface
            '0.4,0.1',     # Layer between two depths below land surface
            '1,0.4' ,   # Layer between two depths below land surface
            '2,1'],   # Layer between two depths below land surface
        'HTGL':['2',       #  Specified height above ground
            '10'],       #  Specified height above ground
            }


# request a template
response = rc.get_control_file_template(dsnum)

print("Template:")
print(response)

# read template
rq_template = response['data']['template']

# Parse the string
template = rc.read_control_file(rq_template)

lev_list = ['{}:{}'.format(k,'/'.join(v)) for k, v in levs_isb.items()]
# Insert parameters
template['dataset'] = dsnum
template['date'] = startdate+'/to/'+enddate
template['param'] = '/'.join(params)
template['oformat'] = oformat
template['product'] = product
template['griddef'] = grid
template['level'] = ';'.join(lev_list)
template['gridproj'] = 'latLon'
template['datetype'] = 'init'

#del template['level']
del template['nlat'] #= 90
del template['slat'] #= -90
del template['wlon'] #=-180
del template['elon'] #= 180
del template['groupindex']
del template['compression']
del template['targetdir']


print("")
print("Request:")
print(template)

# Now We can submit a request
response = rc.submit_json(template)
print("")
print("Response:")
print(response)

assert response['http_response'] == 200
assert response['error_messages'] == []

print("Response confirmed")

# Now, wait for the request to be ready
rqst_id = response['data']['request_id']
print("request Id:" + str(rqst_id))

check_ready(rqst_id)

# If the program get's here, then the request files are ready
# Start downloading
print("Downloading starts...")
re_dwnload =  True
retrycount=0
while(re_dwnload and retrycount <= 5):
        re_dwnload = False
        try:
                print("downloading datasets....")
                rc.download(rqst_id)
                retrycount = 0
        except Exception as e:
                print(e)
                print()
                print("retrying downloads in 5 seconds...")
                sleep(5)
                re_dwnload = True
                retrycount += 1

print("finished downloading successfully")
# Optionally purge request
rc.purge_request(rqst_id)

print("Download finished")
