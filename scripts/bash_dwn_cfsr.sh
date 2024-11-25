#!/bin/bash

prsstartdate=198006300000
prsenddate=198007020000
sfcstartdate=198006300000
sfcenddate=198010050000
singlemultiyears=1


#============ Main excution =================================#

source /apps/chpc/bio/anaconda3-2020.02/etc/profile.d/conda.sh
conda activate

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

prssub1="${prsstartdate:4:8}"
prssub2="${prsenddate:4:8}"
sfcsub1="${sfcstartdate:4:8}"
sfcsub2="${sfcenddate:4:8}"

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
			rm *.ipvgrbh*.grb2*

			# rename pressure files
			for p in $( ls *.pgrbh.grb2* ); do mv "$p" "plv_$p"; done
			
		else
			rm pgbl*.grb2*
			rm diab*.grb2*

			# rename pressure files
			for p in $( ls pgbh*.grb2* ); do mv "$p" "plv_$p"; done
		fi

		prssub1="01010000"	
	fi

#****************************************************************************************************
# Download surface files
#*****************************************************************************************************
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
			rm *.ipvgrbh.grb2*
		else
			rm pgbl*.grb2*
		fi

		sfcsub1="01010000"
	fi

	# remove unused scripts and files
	rm *.csh
	rm *.sh
	rm *.bat
	cd ../../
done
