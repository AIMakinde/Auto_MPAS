#!/bin/bash

prsstartdate=198006300000
prsenddate=198007020000
sfcstartdate=198006300000
sfcenddate=198010050000
tstep=6
datatype="era5"  	# OPTIONS:  "cfsr" | "era5"
format=0			# 0 - grib2 | 1 - netcdf
singlemultiyears=1


#============ Main excution =================================#

source /apps/chpc/bio/anaconda3-2020.02/etc/profile.d/conda.sh

if [[ $datatype == "era5" ]]
then 
	conda activate cdsenv
elif [[ $datatype == "cfsr" ]]
then
	conda activate
fi



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


if [[ $datatype == "era5" ]]
then
	prssub1="${prsstartdate:0:4}-${prsstartdate:4:2}-${prsstartdate:6:2}T${prsstartdate:8:2}"
	prssub2="${prsenddate:0:4}-${prsenddate:4:2}-${prsenddate:6:2}T${prsenddate:8:2}"
	sfcsub1="${sfcstartdate:0:4}-${sfcstartdate:4:2}-${sfcstartdate:6:2}T${sfcstartdate:8:2}"
	sfcsub2="${sfcenddate:0:4}-${sfcenddate:4:2}-${sfcenddate:6:2}T${sfcenddate:8:2}"

elif [[ $datatype == "cfsr" ]]
then
	prssub1="${prsstartdate:4:8}"
	prssub2="${prsenddate:4:8}"
	sfcsub1="${sfcstartdate:4:8}"
	sfcsub2="${sfcenddate:4:8}"
else
	echo "Cannot determine which data set to download"
	exit 0
fi


# if [[ ${singlemultiyears} -ge 1 ]]
# then
# 	dendyr=${dstartyr}
# fi

for d in $( seq $dstartyr $dendyr )
do
	
	echo ""
	echo "preparing to download forcing dataset for ${d}..."
	cpt="${d}"
	
	if [[ ${singlemultiyears} -eq 1 ]]; then cpt="${dstartyr}-${dendyr}"; fi

	# create data directory if not exist
	mkdir -p "${cpt}/raw"
	cp *.py ./${cpt}/raw
	cp *.txt ./${cpt}/raw
	cd "${cpt}/raw"

	nmstr="dsnum = 'ds093.0'"
	dnm=$(( d + 0 ))
	dnm2=$(( d + 1 ))
	prsnd=${prssub2}

	if [[ ${dnm} -lt ${prsendyr} ]]
	then
		prsnd="01010000"
	fi

	if [[ ${dnm} -gt 2010 ]]
	then
		nmstr="dsnum = 'ds094.0'"
	fi
	
#****************************************************************************************************
# Download Pressure files
#*****************************************************************************************************
	
	if [[ $datatype == "era5" ]]
	then
		# Download pressure files
		echo "Setting up downloading..."
		echo "Starting downloads at pressure levels"
		# -u allows python to run while shell stdout is being pipped to log file
		#python -u era5_dwn_prslev.py --start_time=${prssub1} --end_time=${prssub2} --time_step=${tstep}
		# prssub1="01010000"
		echo "Done."

	elif [[ $datatype == "cfsr" ]]
	then
		#echo "curr=${dnm}  start=${prsstartyr}   end=${prsendyr}"
		if [[ ${dnm} -ge ${prsstartyr} ]] && [[ ${dnm} -le ${prsendyr} ]]
		then
			if [[ ${dnm} -ge ${prsendyr}  ]]; then dnm2=${prsendyr}; fi
			dsstr="startdate = '${dnm}${prssub1}'"
			destr="enddate = '${dnm2}${prsnd}'"
			sed -i "11s|.*|${nmstr}|" cfsr_dwn_prslev.py
			sed -i "12s|.*|${dsstr}|" cfsr_dwn_prslev.py
			sed -i "13s|.*|${destr}|" cfsr_dwn_prslev.py

			echo ""
			echo "Starting pressure levels download..."

			# -u allows python to run while shell stdout is being pipped to log file
			python -u cfsr_dwn_prslev.py
			
			# remove duplicate dataset
			if [[ ${dnm} -gt 2010 ]]
			then
				# remove duplicate dataset
				rm *.ipvgrbh*.grb2

				# rename pressure files
				for p in $( ls *.pgrbh.grb2 ); do mv "$p" "plv_$p"; done
				
			else
				rm pgbl*.grb2
				rm diab*.grb2

				# rename pressure files
				for p in $( ls pgbh*.grb2 ); do mv "$p" "plv_$p"; done
			fi

			prssub1="01010000"	
		fi
	fi

#****************************************************************************************************
# Download surface files
#*****************************************************************************************************
	if [[ $datatype == "era5" ]]
	then
		# Download surface and invariant files
		echo ""
		echo "Starting downloads at surface..."
		python -u era5_dwn_sfc.py --start_time=${sfcsub1} --end_time=${sfcsub2} --time_step=${tstep}
		echo "Done."
	elif [[ $datatype == "cfsr" ]]
	then
		dnm=$(( d + 0 ))
		dnm2=$(( d + 1 ))
		sfcnd=${sfcsub2}
		sfcst=${sfcsub1}

		if [[ ${dnm} -lt ${sfcendyr} ]]
		then
			sfcnd="01010000"
		fi
		if [[ ${d} -gt ${sfcstartyr} ]]
		then
			dnm=$(( d - 1 ))
			sfcst="12310000"
		fi

		if [[ ${dnm} -ge ${sfcstartyr} ]] && [[ ${dnm} -le ${sfcendyr} ]]
		then
			if [[ ${dnm} -ge ${sfcendyr}  ]]; then dnm2=${sfcendyr}; fi
			echo ""
			echo "setting params for surface download..."

			dsstr="startdate = '${dnm}${sfcst}'"
			destr="enddate = '${dnm2}${sfcnd}'"
			sed -i "11s|.*|${nmstr}|" cfsr_dwn_sfc.py
			sed -i "12s|.*|${dsstr}|" cfsr_dwn_sfc.py
			sed -i "13s|.*|${destr}|" cfsr_dwn_sfc.py

			echo ""
			echo "starting surface download..."

			# -u allows python to run while shell stdout is being pipped to log file
			python -u cfsr_dwn_sfc.py
			
			# remove duplicate dataset
			if [[ ${dnm} -gt 2010 ]]
			then
				# remove duplicate dataset
				rm *.ipvgrbh.grb2
			else
				rm pgbl*.grb2
			fi

			sfcsub1="01010000"
		fi
	fi


#****************************************************************************************************
# If Downloading ERA5 dataset, merge surface files into pressure file
#*****************************************************************************************************
	if [[ $datatype == "era5" ]]
	then
		# Expected hourly ERA file datasets
		# Each file contains a day worth data

		# Check if needed pressure and surface file exist
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
					filedate=${dfile2:9}
					mfile="merged_era5_${filedate}"

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
	fi
	# remove unused scripts and files
	rm *.csh
	rm *.sh
	rm *.bat
	cd ../../
done
