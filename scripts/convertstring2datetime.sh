#!/bin/bash
# Created On: 21-08-2021
# By: AI Makinde
# Last Modified: 21-08-2021
# Contact: mckynde@gmail.com


#====================================================#
# This script converts datetime string to date and time.
# It takes a datetime string and returns a date and time
#
#
# USAGE:
# sh convertdatestring2date.sh "1980-10-05_00:00:00"
#

dtstring=$1
rdate="${dtstring//_/ }"

# extract the year with the syntax ${parameter:offset:length}
echo $(date -d ${rdate} +"%Y-%m-%d_%H:%M:%S")  # = 1980-06-18_00:00:00
#rtm=$(date -d ${rtime} +"%H%M%S")