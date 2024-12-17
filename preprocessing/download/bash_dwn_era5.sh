#!/bin/bash

prsstartdate=198006300000
prsenddate=198007020000
sfcstartdate=198006300000
sfcenddate=198010050000
tstep=6
singlemultiyears=1


#============ Main excution =================================#

source /apps/chpc/bio/anaconda3-2020.02/etc/profile.d/conda.sh
conda activate cdsenv

prsstartyr=${prsstartdate:0:4}
prsendyr=${prsenddate:0:4}
sfcstartyr=${sfcstartdate:0:4}
sfcendyr=${sfcenddate:0:4}

# choose the lowest year
dstartyr=${prsstartyr}
if [[ ${sfcstartyr} -le ${dstarty} ]]
then
	dstarty=${sfcstartyr}
fi

# choose the highest year
dendyr=${prsendyr}
if [[ $sfcendyr -ge $dendyr ]]
then
	dendyr=${sfcendyr}
fi

prssub1="${prsstartdate:0:4}-${prsstartdate:4:2}-${prsstartdate:6:2}T${prsstartdate:8:2}"
prssub2="${prsenddate:0:4}-${prsenddate:4:2}-${prsenddate:6:2}T${prsenddate:8:2}"
sfcsub1="${sfcstartdate:0:4}-${sfcstartdate:4:2}-${sfcstartdate:6:2}T${sfcstartdate:8:2}"
sfcsub2="${sfcenddate:0:4}-${sfcenddate:4:2}-${sfcenddate:6:2}T${sfcenddate:8:2}"





#======================== Start Internal functions ========================================#


function GETFILEDATE(){

	rfile=$1
	# rfile should have a name template similar
	# to era5_sfc_20200731.grib

    # get the lenght of rfile
    namelen=$( echo ${#rfile} )

    if [[ $namelen -gt 9 ]]
    then
        # lenght of 'era5_sfc_' is 9
        len=$(( namelen-9 ))
		dlen=$(( len-5))

        # extract the datetime with the syntax ${parameter:offset:length}
        fdate=${rfile:9:$len}

        # # remove the .grib
        # fdate=${fdate:0:$((len-6))}

        # return the value
        echo $fdate | sed 's/ *$//g'
    else
        echo ""
    fi
}


#======================= End internal functions ==========================================#









# =========================== Main Execution ============================================ #

for d in $( seq $dstartyr 1 $dendyr )
do
	
	echo ""
	echo "preparing to download forcing dataset for ${d}..."
	cpt="${d}"
	
	if [[ ${singlemultiyears} -eq 1 ]]; then cpt="${dstartyr}-${dendyr}"; fi

	# create data directory if not exist
	mkdir -p "${cpt}/raw"
	cp *.py ./${cpt}/raw
	cd "${cpt}/raw"

	nmstr="dsnum = 'ds093.0'"
	dnm=$(( d + 0 ))
	dnm2=$(( d + 1 ))
	prsnd=${prssub2}

	if [[ ${dnm} -lt ${prsendyr} ]]
	then
		prsnd="01010000"
	fi
	
#****************************************************************************************************
# Download Pressure files
#*****************************************************************************************************

	# Download pressure files
	echo "Setting up downloading..."
	echo "Starting downloads at pressure levels"
	# -u allows python to run while shell stdout is being pipped to log file
	#python -u era5_dwn_prslev.py --start_time=${prssub1} --end_time=${prssub2} --time_step=${tstep}
	# prssub1="01010000"
	echo "Done."

	
#****************************************************************************************************
# Download Surface files
#*****************************************************************************************************

	# Download surface and invariant files
	echo ""
	echo "Starting downloads at surface..."
	python -u era5_dwn_sfc.py --start_time=${sfcsub1} --end_time=${sfcsub2} --time_step=${tstep}
	echo "Done."

done



# Expected hourly ERA file datasets
# Each file contains a day worth data

# Check if need pressure and surface file exist
echo ""
echo "Cheking for and merging corresponding pressure and surface datasets..."


for yr in $(seq ${dstartyr} 1 ${dendyr});
do
	sfile="era5_sfc_${yr}*.grib"
	pfile="era5_prslv_${yr}*.grib"

	pfoundfiles=($(ls ${pfile}))
	sfoundfiles=($(ls ${sfile}))
	pfound=${#pfoundfiles[@]}
	sfound=${#sfoundfiles[@]}

	if [[ ${pfound} -ne 0  &&   ${sfound} -ne 0  && ${pfound} -eq ${sfound} ]]
	then
#		sfoundfiles+=($sfile)
#		pfoundfiles+=($pfile)
#		nfound=$(( nfound + 1 ))

		for ifile in $( seq 0 $((pfound -1 )) );
		do
			dfile1=${pfoundfiles[$ifile]}
			dfile2=${sfoundfiles[$ifile]}
			filedate=$( GETFILEDATE ${dfile2} )
			mfile="merged_era5_${filedate}.grib"

			# Only merge if not merged file exist
			if [[ ! -f ${mfile} && ! -z ${dfile1} && ! -z ${dfile2} ]]
			then
				echo "[+]   merging ${dfile1} and ${dfile2} into ${mfile}..."
				cat ${dfile1} ${dfile2} > merged_era5_${filedate}
			else
				echo "[+]   Skipped merging ${dfile1} and ${dfile2} because ${mfile} was found."
			fi
		done
	else
		echo "[+]   Could not find either of the '${sfile}' and '${pfile}'"
	fi
done

cd ../../
echo "Done merging datasets."
