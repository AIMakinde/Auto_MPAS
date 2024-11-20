import rdams_client as rc
import time
import sys


def check_ready(rqst_id, wait_interval=120):
    """Checks if a request is ready."""
    for i in range(100): # 100 is arbitrary. Would wait 200 minutes for request
        res = rc.get_status(rqst_id)
        request_status = res['data']['status']
        if request_status == 'Completed':
            return True
        print(request_status)
        print('Not yet available. Waiting ' + str(wait_interval) + ' seconds.' )
        time.sleep(wait_interval)
    return False