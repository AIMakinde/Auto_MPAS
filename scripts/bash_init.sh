#!/bin/bash

startyr='2022'
endyr='2022'
startdate='04-07_00:00:00'  # mon day hr min sec
enddate='04-15_00:00:00'  # mon day hr min sec
datapath='/home/amakinde/lustre/sims/mpas/test_240km_2/data/cfsr'
opt="init.opt"
jobsig="init.sig"
ismultipleshortruns=0
rsltn='240km'

#============ Main execution begins =================================#

start=$(( startyr + 0 ))
end=$(( endyr + 0 ))
prsstart="${startdate:0:8}"  # picks mon day and hour
stmon="${startdate:0:2}"
edmon="${enddate:0:2}"

# read option file and 
# pickup from last stop
if [ -f "$opt" ]
then
	while IFS='=' read -r ky vl
	do
		if [ "$ky" == "current" ]
		then
			start=$vl
		elif [ "$ky" == "next" ] && [ ! -z "$vl" ]
		then
			start=$vl
		fi
	done < $opt
fi

echo "starting automated mpas initialization..."

for d in $( seq ${start} ${end} )
do
	dst=${d}
	dnd=${d}

	if [ ${ismultipleshortruns} -le 0 ]
	then
		# its a long year run
		dpath="${datapath}/${start}-${end}"
		dnd=${end}
	else
		dpath="${datapath}/${d}"
	fi

	echo ""
	echo "preparing to initialize model for ${dst}..."
	dsstr="    config_start_time = '${dst}-${startdate}'"
	destr="    config_stop_time = '${dnd}-${enddate}'"
	sed -i "7s/.*/${dsstr}/" namelist.init_atmosphere_met
	sed -i "8s/.*/${destr}/" namelist.init_atmosphere_met

	sed -i "8s/.*/${dsstr}/" namelist.init_atmosphere_sst
	sed -i "9s/.*/${destr}/" namelist.init_atmosphere_sst

	sed -i "7s/.*/${dsstr}/" namelist.init_atmosphere_static
	sed -i "8s/.*/${destr}/" namelist.init_atmosphere_static

	ttle="#PBS -N ${dst}_${rsltn}_MPASInit"
	sed -i "7s/.*/${ttle}/" run_mpas_auto_init.qsub

	echo "linking forcing files..."
	ln -sf ${dpath}/PRES\:$d-${prsstart} .

	if [ ${ismultipleshortruns} -le 0 ]
	then
		for m in $( seq -w "${start}" "${end}" ); do ln -sf ${dpath}/SST\:${m}-* . ; done
#        ln -sf ${dpath}/SST\:$d-10-{01..04}* .
	else
		for m in $( seq -w "${stmon}" "${edmon}" ); do ln -sf ${dpath}/SST\:$d-${m}-* . ; done
	fi


	echo "submitting mpas init qsub script..."
	rm init.sig
	qsub run_mpas_auto_init.qsub

	echo "job submitted"
	echo "waiting for job to finish..."
	
	while [ ! -f "$jobsig" ]
	do
		sleep 5m # sleep for 5 minutes
	done

	# move result
	mkdir "${dst}"
	mv x*init.nc ./${dst}
	mv x*static.nc ./${dst}
	mv x*sfc_update.nc ./${dst}
	cp x*grid.nc ./${dst}
	mv log.* ./${dst}

	if [ ${ismultipleshortruns} -le 0 ]
	then
		# its a long year run
		break
	fi
	
done

echo "All done"
