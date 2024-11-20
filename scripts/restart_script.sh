#!/bin/bash
# Created On: 5-12-2020
# By: AI Makinde
# Last Modified: 20-09-2021
# Contact: mckynde@gmail.com


#=========== Description ==================================
# This script is meant to re-submit simulations (run_mpas_atmos.qsub) until 
# the run or simulation has finished (reached end date)
#
# To use this script, make sure to have setup the following
# files normally as you will do
# 1. streams.atmosphere file (must have the restart section setup
#    with a restart file name template as   restart.YYYY-MM-DD_HH.MM.SS.nc
# 2. namelist.atmosphere file
# 3. run_mpas_atmos.qsub


#====== Usage =================================================
# PLEASE RUN IN BACKGROUD USING SCREEN
#
# sh restart_script.sh
#
#==============================================================


#=========== Script Start ==================================

SIM_STARTDATE='1999-01-01_00:00:00'
SIM_ENDDATE='2001-01-02_00:00:00'
Ext_SIM_Duration_BY=2      # Number of days to go beyond the specified simulation end date
WALL_TIME=96
MIN_WAIT=15m    # hour = h, minute = m, seconds = s
N_ATTEMPT=4
USERNAME="$( echo $USER )"
ROUTPUT="log.restart_0000.out"
continous_monitor=true  # if TRUE the MIN_WAIT will not be used any more












#=========== CAUTION ==========================
# Please do not edit the
# following configurations
# they are being used by the code
# for house keeping





# Parse commandline arguments
simstartdate=$1
simenddate=$2

#echo "param from commandline start date ${simstartdate}"
#echo "param from commandline end date ${simenddate}"

if [ ! -z "${simstartdate}" ]
then
    SIM_STARTDATE="${simstartdate}"
fi


if [ ! -z "${simenddate}" ]
then
    SIM_ENDDATE="$simenddate"
fi

#echo "modified start date ${SIM_STARTDATE}"
#echo "modified end date ${SIM_ENDDATE}"

# Initialize varaibles
CONFIG_KEY0='config_run_duration'
CONFIG_KEY1='config_start_time'
CONFIG_KEY2='config_do_restart'
CURRENT_RESTART=${SIM_STARTDATE}
LAST_RESTART=''
JOB_ID=''
SLP=0
IS_FIRST_RUN=0



function STRING2DATETIME() {
    #====================================================#
    # This converts datetime string to date and time.
    # Arg 1:  a datetime string (1980-10-05_00:00:00)
    # Arg 2:  return format (1 - in total seconds, 2 - date string (2021-09-03), 3 - date time string (2021-09-03_00:00:00) )
    #
    # USAGE:
    # sh convertdatestring2date.sh "1980-10-05_00:00:00" 1
    #

    dtstring=$1
    opt=$2
    opt=$(( opt + 0 ))

    # if opt is empty then set it to 1
    if [[ ${opt} -le 0 ]]; then opt=1; fi

    frdate="${dtstring//./:}"
    rdate="${frdate//_/ }"
    #echo "STRING2DATETIME: dstring ${dtstring},  rdate ${rdate}"
    # extract the year with the syntax ${parameter:offset:length}
    
    if [[ ${opt} -eq 1 ]]
    then 
        #echo " opt = 1"
        echo $( date -d "${rdate}" +"%s")  # = 167354 seconds
    elif [[ ${opt} -eq 2 ]]
    then
        #echo " opt = 2"
        echo $( date -d "${rdate}" +"%Y-%m-%d")  # = 1980-06-18
    elif [[ ${opt} -eq 3 ]]
    then
        #echo " opt = 3"
        echo $( date -d "${rdate}" +"%Y-%m-%d_%H:%M:%S")  # = 1980-06-18_00:00:00
    fi
    #rtm=$(date -d ${rtime} +"%H%M%S")
}

function GETLASTRESTART(){
    # List all files, sort it by time
    # filter it by the name 'restart'
    # pick the first one in the list

    rfile=$( ls --sort=time | grep 'restart.*nc' | head -1 )

    # rfile should have a name template similar
    # to restart.2020-07-31.00.00.00

    # get the lenght of rfile
    namelen=$( echo ${#rfile} )

    if [[ $namelen -gt 7 ]]
    then
        # lenght of 'restart' is 7
        len=$(( namelen-7 ))

        # extract the datetime with the syntax ${parameter:offset:length}
        lastrestart=${rfile:8:$len}

        # remove the .nc
        lastrestart=${lastrestart:0:$((len-4))}

        # replace all "." with ":"
        lastrestart_trm=${lastrestart//./:}
        
        # return the value
        echo $lastrestart_trm | sed 's/ *$//g'
    else
        echo ""
    fi
}



function CHECKSIMENDDATE(){

    #********************************************************#
    # this function accepts current restart date as parameter
    #
    # Expected format : 1980-08-01_00:00:00
    #********************************************************#
    
    currRestart=$1
    result=1
    # if current restartdate is empty
    # return true meaning current restartdate is less than simulation enddate
    if [ -z "${currRestart}" ]
    then
        result=1
    else
        rstart=$( STRING2DATETIME "${currRestart}" )
        simend=$( STRING2DATETIME "${SIM_ENDDATE}" )
        
        #echo "restartdate ${rstart} , simenddate  ${simend}"
        # if restartdate is greater than or equal to simulation enddate
        # return false,  the simulation is ended.
        if [[ ${rstart} -ge ${simend} ]]
        then
            result=0
        fi
    fi

    echo ${result}   
}

function GETDAYDIFF(){
    tmp_std=$1
    tmp_edd=$2

    #echo "std = ${tmp_std}, edd = ${tmp_edd} "
    std=${tmp_std%"_00:00:00"}
    edd=${tmp_edd%"_00:00:00"}

    #echo "trimmed start date is ${std}"
    #echo "trimmed end date is ${edd}"
    start_ts=$( STRING2DATETIME "${std}" )
    end_ts=$( STRING2DATETIME "${edd}" )

    #echo "start date is $start_ts"
    #echo "end date is $end_ts"

    diff=$( printf "%.0f" $( echo "scale=2; ( $end_ts - $start_ts )/(60*60*24)" | bc ) )
    
    if [[ ${diff} -lt 0 ]]
    then 
        echo "Simulation end date cannot be less than current/start simulation date"
        echo "startdate = ${tmp_std}, enddate = ${tmp_edd} "
        KILLJOB
    else
        echo "${diff}"
    fi
}

function MODIFYNAMELIST4RESTART(){
    echo "Modifying namelist.atmosphere for restart"

    ttdays=$( GETDAYDIFF "${CURRENT_RESTART}" "${SIM_ENDDATE}" )
    xtdays=$(( ttdays + Ext_SIM_Duration_BY ))
    duration="${xtdays}_00:00:00"

    ndline="    ${CONFIG_KEY0} = '${duration}'"
    newline="    ${CONFIG_KEY1} = '${CURRENT_RESTART}'"
    rstart="    ${CONFIG_KEY2} = true"

    echo "using the following keys..."
    echo "key 1 : ${CONFIG_KEY0}"
    echo "key 2 : ${CONFIG_KEY1}"
    echo "key 3 : ${CONFIG_KEY2}"

    cp namelist.atmosphere namelist.atmosphere_$(date +%s)

    # get line number(grep -n) of CONFIG_KEY and ignore case sensitivity (grep -i)
    lnum0="$(grep -n -i "${CONFIG_KEY0}" namelist.atmosphere | head -n 1 | cut -d: -f1)"
    lnum1="$(grep -n -i "${CONFIG_KEY1}" namelist.atmosphere | head -n 1 | cut -d: -f1)"
    lnum2="$(grep -n -i "${CONFIG_KEY2}" namelist.atmosphere | head -n 1 | cut -d: -f1)"

 #   echo "located key 1 on line ${lnum0}"
 #   echo "located key 2 on line ${lnum1}"
 #   echo "located key 3 on line ${lnum2}"

    sed -i "${lnum0}s/.*/${ndline}/" namelist.atmosphere
    sed -i "${lnum1}s/.*/${newline}/" namelist.atmosphere
    sed -i "${lnum2}s/.*/${rstart}/" namelist.atmosphere

    echo "namelist.atmosphere update completed"
}


function MODIFYNAMELIST4FIRSTRUN(){
    echo "Modifying namelist.atmosphere for first run"

    echo "current restart is ${CURRENT_RESTART}"
    echo "simulation end date is ${SIM_ENDDATE}"
    ttdays=$( GETDAYDIFF "${CURRENT_RESTART}" "${SIM_ENDDATE}" )
    xtdays=$(( ttdays + Ext_SIM_Duration_BY ))
    duration="${xtdays}_00:00:00"

    ndline="    ${CONFIG_KEY0} = '${duration}'"
    newline="    ${CONFIG_KEY1} = '${CURRENT_RESTART}'"
    rstart="    ${CONFIG_KEY2} = false"

    echo "using the following keys..."
    echo "key 1 : ${CONFIG_KEY0}"
    echo "key 2 : ${CONFIG_KEY1}"
    echo "key 3 : ${CONFIG_KEY2}"

#    cp namelist.atmosphere namelist.atmosphere_$(date +%s)

    # get line number(grep -n) of CONFIG_KEY and ignore case sensitivity (grep -i)
    lnum0="$( grep -n -i "${CONFIG_KEY0}" namelist.atmosphere | head -n 1 | cut -d: -f1 )"
    lnum1="$( grep -n -i "${CONFIG_KEY1}" namelist.atmosphere | head -n 1 | cut -d: -f1 )"
    lnum2="$( grep -n -i "${CONFIG_KEY2}" namelist.atmosphere | head -n 1 | cut -d: -f1 )"

#    echo "located key 1 on line ${lnum0}"
#    echo "located key 2 on line ${lnum1}"
#    echo "located key 3 on line ${lnum2}"

    sed -i "${lnum0}s/.*/${ndline}/" namelist.atmosphere
    sed -i "${lnum1}s/.*/${newline}/" namelist.atmosphere
    sed -i "${lnum2}s/.*/${rstart}/" namelist.atmosphere

    echo "namelist.atmosphere update for first run completed"
}


function GETJOBSTATUS(){

    # get job statistic
    jobstat=$( qstat | grep -E "${JOB_ID}.*${USERNAME}" )
    
    if [[ -z "${JOB_ID}" || -z "$jobstat" ]]
    then
        # this means no job has started
        echo "N"
    elif [ ! -z $( echo ${jobstat} | grep -q -i "cannot connect to server" ) ]
    then
        # expecting something like
        # "qstat cannot connect to server (errno=15010)""
        # this means the server is not responding
        error_msg=${jobstat}
        echo "W"
    else
        # return the actual status
        jobst="$(tr -s ' ' <<< "${jobstat}" | cut -d ' ' -f 5)"
        echo "${jobst}"
    fi
}


function MOVE1STEPBACKWARD(){

    # CURRENT_RESTART format is 1980-06-01_00:00:00
    crRstart=$( STRING2DATETIME "${CURRENT_RESTART}" )
    simEnddt=$( STRING2DATETIME "${SIM_ENDDATE}" )
    
    # check if current restart date is greater or equal to the simulation end date.
    # if equal or greater, no need to restart, return false.
    if [[ ${crRstart} -ge ${simEnddt} ]]
    then
            # return false
            echo 0
    else
            # hide the latest restart file, so the restart script sees the previous restart file as the latest

            mkdir -p hidden
            # replace ":" with "."
            mv restart.${CURRENT_RESTART//:/.}*.nc ./hidden

            # return true
            echo 1
    fi
}


function PREPOUTPUT4RESTART(){

    # hides all output file (diag, history and restart) greater than the
    # specified restart datetime

    # format 1980-08-01_00.00.00
    tmp=$1
    #echo "prep restart date: $rstart"
    # extract the year with the syntax ${parameter:offset:length}
    rdt=$( STRING2DATETIME "${tmp}" )    # = 19800618


#========================================================#
#    for diag files
#========================================================#
    # sort file in descending order (i.e from the latest to previous)
    files=( $( ls --sort=time diag*.nc ) )

    # create a hidden folder if not exist
    mkdir -p ./hidden

    # compare each file with the specified restart datetime
    # move all files greater than the specified restart datetime to hidden folder
    for file in "${files[@]}"
    do
        filename=$(basename "$file")
        #extension=${filename##*.}
        filename=${filename%.*}
        arry=(${filename//./ })
        ddate=${arry[1]}
        dt=$( STRING2DATETIME "${ddate}" )  # = 19800618

        # if result of grep is not empy, the files is thesame as the restart file, thus stop moving
        if [ ${dt} -le ${rdt} ]
        then
            #echo "found ${file}"
            #echo " breaking loop..."
            continue
        else
            #echo "moving ${file}"
            mv "${file}" ./hidden/
        fi
    done



#========================================================#
#    for history files
#========================================================#
    # sort file in descending order (i.e from the latest to previous)
    files=( $( ls --sort=time history*.nc ) )

    # create a hidden folder if not exist
    mkdir -p ./hidden

    # compare each file with the specified restart datetime
    # move all files greater than the specified restart datetime to hidden folder
    for file in "${files[@]}"
    do
	    filename=$(basename "$file")
        #extension=${filename##*.}
        filename=${filename%.*}
        arry=( ${filename//./ } )
        ddate=${arry[1]}
        dt=$( STRING2DATETIME "${ddate}" )  # = 19800618

        if [[ ${dt} -le ${rdt} ]]
        then
            #echo "found ${file}"
            #echo " breaking loop..."
            continue
        else
            #echo "moving ${file}"
            mv "${file}" ./hidden/
        fi
    done


#========================================================#
#    for restart files
#========================================================#
    # sort file in descending order (i.e from the latest to previous)
    files=( $( ls --sort=time restart*.nc ) )

    # create a hidden folder if not exist
    mkdir -p ./hidden

    # compare each file with the specified restart datetime
    # move all files greater than the specified restart datetime to hidden folder
    for file in "${files[@]}"
    do
	    filename=$(basename "$file")
        #extension=${filename##*.}
        filename=${filename%.*}
        arry=( ${filename//./ } )
        ddate=${arry[1]}
        dt=$( STRING2DATETIME "${ddate}" )  # = 19800618

        if [[ ${dt} -le ${rdt} ]]
        then
            #echo "found ${file}"
            #echo " breaking loop..."
            continue
        else
            #echo "moving ${file}"
            mv "${file}" ./hidden/
        fi
    done
}


function KILLJOB(){

    if [ -z "${JOB_ID}" ]
    then
        echo "No Job is currently running"
        return
    fi
    # get the JOB_ID number only
    # Check for the job with JOB_ID and username
    # trim all repeated spaces
    # cut it into columns using space as delimeter and pick the first column
    # cut the result into columns using dot(.) and pick the first column
    currJob=$( qstat | grep -E "${JOB_ID}.*${USERNAME}" | tr -s ' ' | cut -d ' ' -f  1 | cut -d '.' -f 1 )
    if [ ! -z "$currJob" ]
    then
        echo -ne "\r\n"
        echo "killing the currently running Job (${currJob})"
        $( qdel ${currJob} )
        echo "Job (${currJob}) killed"
    else
        echo "No job is currently running"
    fi          
}


function StartRestart(){

    attempted=0
    # creating backup of namelist.atmosphere before restart
    echo "[$(date)]    creating backup of namelist.atmosphere"
    cp namelist.atmosphere namelist.atmosphere_bak

    # check for ongoing simulation using both the username
    # and the job id, initially job_id will be empty
    # using the job_id allows the user to run another job
    # and it won't alter or affect this restart script

    isRunning=""
    isRunning=$( GETJOBSTATUS )
    #echo "${isRunning}"

    # check if isRunning is empty
    # if its empty, it means no job is running,
    # we can start another run
    # if not, then let the script(thread) sleep for at most 1 day
    if [[ -z "$isRunning" || "${isRunning}" -eq "N" ]]
    then
        echo "No Job is running yet or all jobs has stopped"
        LAST_RESTART=${CURRENT_RESTART}

        if [ ${IS_FIRST_RUN} -le 0 ]
        then
            con1=$( GETLASTRESTART ) 
            #echo "GETLASTRESTART  ${con1}"
            if [ ! -z "$con1" ]
            then
                CURRENT_RESTART=$con1
                echo "[$(date)]    Starting the first restart (${con1//:/.})"
                # modify the namelist for restart
                MODIFYNAMELIST4RESTART
                
                IS_FIRST_RUN=1
            else
                CURRENT_RESTART=$SIM_STARTDATE
                echo "[$(date)]    Starting the first run with restart enabled"
		
		# modify namelist file for first run
                MODIFYNAMELIST4FIRSTRUN

                IS_FIRST_RUN=1  
            fi
        else
            CURRENT_RESTART=$(GETLASTRESTART)
            echo "starting the ${CURRENT_RESTART} restart"
           
            # modify the namelist for restart
            MODIFYNAMELIST4RESTART
            
            IS_FIRST_RUN=1
        fi
        # update LAST_RESTART before runing the model
        LAST_RESTART=$CURRENT_RESTART

#===============================================================================#
        echo "Starting simulation with startdate set to ${CURRENT_RESTART}"
        durn=$( GETDAYDIFF "${CURRENT_RESTART}" "${SIM_ENDDATE}" )
        echo "and Duration set to $(( durn + Ext_SIM_Duration_BY )) "
        #echo "job ran"
	
	# moving potential overlapping output files to a hidden folder
	# to avoid MPAS giving a "clobber not specified for file" error

	# replace all occurence of ':' with '.' using ${VARIABLE//PATTERN/REPLACEMENT}
	# single '/' to replace first occurrence i.e. ${VARIABLE/PATTERN/REPLACEMENT}
	PREPOUTPUT4RESTART "${CURRENT_RESTART//:/.}"

        JOB_ID=$(qsub run_mpas_atmos.qsub)
        echo "Job ${JOB_ID} submitted on $(date +%Y-%m-%d_%H:%M:%S)"

        echo -ne "waiting for Job ${JOB_ID} to start...\n"
#================================================================================#

        # check for running job that contains username and job id
        # trim repeated spaces in the result
        # cut the result into columns using space
        # pick the 5th column
        # the result should be R-running or Q-queue or E-error

        status=0
        
        isJobRunning=$( GETJOBSTATUS )
        prog_run="running |."
        prog_wait="waiting  |#"
        prog=""
        qrst=""
        slp_time=30s

        # start a waiting loop
        while [ ! -z "$isJobRunning" ]  
        do
            if [ "$isJobRunning" = "R" ]
            then
                # this is first run
                if [ ${status} = 0 ]
                then
                    echo -ne "\n"
                    echo "[$(date)]    Job (${JOB_ID}) has started"
                    echo " "
                    echo "will now wait till the current job (${JOB_ID}) finishes"
                    echo "You may not notice any activity while waiting"
                    echo "Restart script is now waiting" 
                    status=1
                fi

                lnt=`echo ${#prog_run}`
                if [ ${lnt} -ge 50 ]
                then
                    prog_run="running |"
                fi

                if [ "${continous_monitor}" = "true" ]
                then
                    slp_time=1m
                else
                    SLP=$((SLP+1))
                    SLP=$(expr $WALL_TIME-$SLP | bc)
                    slp_time=${SLP}h
                    if [ $SLP -le 0 ]
                    then
                        SLP=0
                        slp_time=${MIN_WAIT}
                    fi
                fi
                prog_run="${prog_run}."
                prog=${prog_run}
                attempted=0
            elif [ "$isJobRunning" = "Q" ]
            then
                slp_time=30s
                
                lnt=`echo ${#prog_wait}`
                if [ ${lnt} -ge 50 ]
                then
                    prog_wait="waiting |"
                fi
                
                prog_wait="${prog_wait}#"
                prog=${prog_wait}
                attempted=0
            elif [ "$isJobRunning" = "W" ]
            then
                # the server is not responding
                echo "${error_msg}"
                echo "let's assume job is still running"
                prog="retrying to connect with the server.."
                attempted=0
            else  
                if [ $((${N_ATTEMPT} - ${attempted})) -ge 1 ]
                then
                    echo -ne "\r\n"
                    echo "--------[$(date)]--------"
                    echo "Status of Job (${JOB_ID}) was empty"
                    echo "could mean the job was terminated"
                    echo "Restart script will make another attempt"
                    attempted=$(($attempted + 1))
                    #N_ATTEMPT=($N_ATTEMPT- $attempted)
                    sleep 10s
                else
                    echo -ne "\n\r"
                    echo "--------[$(date)]---------"
                    echo "Restart script has made $attempted attempt(s) to get job status but to no avail"         	
                    echo "Restart script will now assume the Job (${JOB_ID}) has finished"
                    # echo "Reason for job (${JOB_ID}) termination not known"
                    # echo "Restart Script terminating..."
                
                    # Kill the last job that was started by this script
                    # KILLJOB
                    # exit
                    prog=""
                    break
                fi
            fi

            # write diagnostic information
            # and sleep the thread
            echo -ne "\r"
            echo -ne "${prog}"
            sleep ${slp_time}

            # update
            isJobRunning=$( GETJOBSTATUS )
        done


        echo -ne "${prog}"
        echo -ne "\r\n"
    else
        echo -ne "\r\n"
        echo "Job ${JOB_ID} is still running after ${SLP}hrs of waiting"
        
        # wait for more time
        SLP=$(expr $WALL_TIME-$SLP | bc)
        tslp=${SLP}h
        UNT="rs"

        if (( ${SLP} <= 0 ))
        then
            SLP=0
            tslp=${MIN_WAIT}
            UNT="in"
        fi
        echo "waiting ${tslp}${UNT} more for the current job to finish..."
        sleep ${tslp}
    fi
}










#========================= Main Execution ================================

# make sure to kill current job 
# when this script forcefully killed

trap KILLJOB SIGINT



# Remove and create the log file
[ -f ${ROUTPUT} ] && rm ${ROUTPUT}
touch ${ROUTPUT}

{ # Start of code block
echo -ne "\n\r"
echo "--------------------------------------------------------------------"
echo "[$(date)]     Starting restart script"
restarting=0
while [[ ! -z "${CURRENT_RESTART}" ]] &&  [[ "${CURRENT_RESTART}" != "${SIM_ENDDATE}" ]] #[ true ]
do
    if [ ${restarting} -ge 1 ]
    then
        echo "[$(date)]    Current simulation (${CURRENT_RESTART}) has finished"
        echo "--------------------------------------------------------------------"
        echo -ne "\n\r"
        echo -ne "\n\r"
        echo "--------------------------------------------------------------------"
        echo "Restarting another run...."
    fi
    
    echo "checking conditions"
    con1=$( GETLASTRESTART ) 

    if [ -z "$con1" ]
    then
        echo "No restart file found"
    else
        echo "Found ${con1//:/.} restart file"
    fi

    # if no restart file and its not first run, stop
    if [ -z "$con1" ] && [ $IS_FIRST_RUN -ge 1 ]
    then
         echo "Nothing to restart. No new restart file again"
         break
    fi

    # if no last restart and its not the first run, stop
    if [ -z "$LAST_RESTART" ] && [ $IS_FIRST_RUN -ge 1 ]
    then
        echo "Nothing to restart, something could have gone wrong"
        break
    fi

    # if last restart date is same with the latest restart file,
    # something could have happend.
    # let's try previous restartdate again
    if [[ "$LAST_RESTART" == "$con1" ]] && [[ $IS_FIRST_RUN -ge 1 ]]
    then
        echo "Restart script will now try 1-step backward from the last restart file ${LAST_RESTART}"
        rmove=$( MOVE1STEPBACKWARD )

        if [[ ${rmove} -le 0 ]]
        then
                echo "Nothing to restart. All restart has finished."
                echo "Last restart: ${LAST_RESTART}"
                echo "--------------------------------------------------------------------"
                break
        fi
    fi

    endsim=$( CHECKSIMENDDATE "${con1}" )
    #echo "CheckSimEnddate  current restart ${con1},  simulation enddate ${SIM_ENDDATE}, result ${endsim}"
    # if sim end date not yet reached, restart
    if [[ ${endsim} -ge 1 ]]
    then
	    StartRestart
    
	    restarting=1
    else
        break
    fi
done

KILLJOB

} 2>&1 | tee -a ${ROUTPUT}
