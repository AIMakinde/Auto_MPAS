from os import truncate, wait
from time import sleep
from requests.exceptions import ChunkedEncodingError
import rdams_client as rc
from rdams_helper import *
import sys


passwd = ""
email = 'mckynde@gmail.com'
dsnum = 'ds093.0'
startdate = '198006010000'
enddate = '198010020000'
oformat = "WMO_GRIB1"
product = "6-hour Forecast"
grid =  "720:361:90N:0E:90S:359.5E:0.5:0.5"    #"0.5-deg x 0.5-deg from 0E to 359.5E and 90N to 90S (720 x 361 Longitude/Latitude)"
filename = "cfsr_prs_"+startdate+"-"+enddate+oformat
params = ['TMP',     #  Temperature
          'ICEC',    # Ice cover
          'LAND'    # Land cover (0=sea, 1=land)
          ]

levs_isb = {'SFC':['0'],       #  Ground or water surface
        }


# request a template
response = rc.get_control_file_template(dsnum)


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
template['ststep']='yes'
#del template['level']
del template['nlat']
del template['slat']
del template['wlon']
del template['elon']

print(template)
print("")

# Now We can submit a request
response = rc.submit_json(template)
print("response:")
print(response)

assert response['http_response'] == 200
assert response['error_messages'] == []

# Now, wait for the request to be ready
rqst_id = response['data']['request_id']
print("request Id:" + str(rqst_id))
check_ready(rqst_id)

# If the program get's here, then the request files are ready
# Start downloading

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

# Optionally purge request
rc.purge_request(rqst_id)
