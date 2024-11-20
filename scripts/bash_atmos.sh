#!/bin/bash
# Created On: 26-01-2021
# By: AI Makinde
# Last Modified: 26-01-2021
# Contact: mckynde@gmail.com



#============  NOTE    =================================================
# THIS SCRIPT DEPENDS ON THE "restart_script.sh". SO PLEASE MAKE SURE ITS
# AVAILABLE AND WELL SETUP.
# THE SCRIPT MODIFY OR OVERRIDE THE START AND END SIMULATION DATES OF
# THE "restart_script.sh"



#=========== Description ==================================
# This script is meant to re-submit mpas job script (run_mpas_atmos.qsub) for
# climatological simulations. for example, you want to run models for August 
# of every year ( say 35 years).
#
# To use this script, make sure to have setup the following
# files normally as you will do for a normal simulation
# 1. streams.atmosphere file (must have the restart section setup
#    with a restart file name template as   restart.YYYY-MM-DD_HH.MM.SS.nc
# 2. namelist.atmosphere file
# 3. run_mpas_atmos.qsub


#====== Usage =================================================
# PLEASE RUN IN BACKGROUD USING SCREEN
#
# sh restart_clim_script.sh
#
#==============================================================




#=========== Configurations ==================================
# PLEASE THE FOLOWING CONFIGURATIONS TO SUIT YOUR RUN
#=============================================================

CLIM_STARTYEAR='1982'
CLIM_ENDYEAR='1982'
CLIM_STARTMON='06'
CLIM_ENDMON='10'
CLIM_STARTDAY='01'
CLIM_ENDDAY='01'
CLIM_STARTHOUR='00'
CLIM_ENDHOUR='00'
rsltn="60km"
ROUTPUT="log.restart_clim_0000.out"







#=========== CAUTION ==========================
# Please do not edit the
# following configurations
# they are being used by the code
# for house keeping


SIM_STARTYEAR=${CLIM_STARTYEAR}
SIM_ENDYEAR=${CLIM_ENDYEAR}
SIM_STARTMON=${CLIM_STARTMON#0}
SIM_ENDMON=${CLIM_ENDMON#0}
SIM_STARTDAY=${CLIM_STARTDAY#0}
SIM_ENDDAY=${CLIM_ENDDAY#0}
SIM_STARTHOUR=${CLIM_STARTHOUR#0}
SIM_ENDHOUR=${CLIM_ENDHOUR#0}



function GETDAYSINMONTH(){
    mon=$1
    yr=$2

    echo $(cal $mon $yr | awk 'NF {DAYS = $NF}; END {print DAYS}')
}



function GETSIMSTARTDATE(){
    simstart="${SIM_STARTYEAR}-${SIM_STARTMON}-${SIM_STARTDAY}_${SIM_STARTHOUR}:00:00"
    echo ${simstart}
}



function GETSIMENDDATE(){
    simend="${SIM_ENDYEAR}-${SIM_ENDMON}-${SIM_ENDDAY}_${SIM_ENDHOUR}:00:00"
    echo ${simend}
}




function CHECKCORRECTDAYS()
{
    yr=$1
    tday=$( GETDAYSINMONTH ${SIM_STARTMON} ${yr} ) # gets total days in the month
    #echo "Total day in ${SIM_STARTMON} is ${tday}"
    startday=$(( SIM_STARTDAY + 0 ))  # force convert to integer
    if [[ ${startday} -gt ${tday} ]]
    then
        SIM_STARTDAY=${tday}
    fi

    tday=$( GETDAYSINMONTH ${SIM_ENDMON} ${yr} ) # gets total days in the month
    endday=$(( SIM_ENDDAY + 0 ))  # force convert to integer
    if [[ ${endday} -gt ${tday} ]]
    then
        SIM_ENDDAY=${tday}
    fi
}





#========================= Main Execution ================================

# Remove and create the log file
[ -f ${ROUTPUT} ] && rm ${ROUTPUT}
touch ${ROUTPUT}

{ # Start of code block
    echo -ne "\n\r"
    echo "--------------------------------------------------------------------"
    echo "[$(date)]     Starting Restart for Climatology Script"
    echo " "
    echo "NOTE:    "
    echo "     This script does not check if your simulation run successfully or not"
    echo "     Make sure to check if each climatology year runs is successful."
    echo "--------------------------------------------------------------------"
    echo " "

    y=$(( CLIM_STARTYEAR + 0))
    CHECKCORRECTDAYS ${y}
    simstartdate=$( GETSIMSTARTDATE )
    simenddate=$( GETSIMENDDATE )

    echo ""
    echo ""
    echo "-------------------------------------------------------------------------"
    echo "[$(date)]     Starting Climatology simulation for ${y}"
    echo "              From: ${simstartdate} "
    echo "              To: ${simenddate} "
    echo "-------------------------------------------------------------------------"

    # remove previous linked nc files
    rm x*.nc

    cp namelist.atmosphere_org namelist.atmosphere

    # link new files
    ln -sf ../mpas_init/${y}/x* .

    ttle="#PBS -N ${y}_${rsltn}-Atmos"
    sed -i "8s/.*/${ttle}/" run_mpas_atmos.qsub

    sh restart_script.sh ${simstartdate} ${simenddate}

    # move output to its directory
    # create directory if it doesn't exist
    mkdir -p ${y}
    mv diag*.nc histroy*.nc restart*.nc ./${y}/
    mv atmos_std* ./${y}/
    mv log.* ./${y}/

    echo "Restart Climatology Script has finished".
} 2>&1 | tee -a ${ROUTPUT}
