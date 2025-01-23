#!/bin/bash

fname="era5_prslv_202204070000.netcdf"
prfx="ensbl"
ptb_lev=3
ptb_time=0
ptb_lon=19
ptb_lat=6
ptb_var="t"
ptb_val=0.0001
ptb_inc=0.0001
nensemble=10


for ens in $( seq 1 1 $nensemble );
do
	echo "generating ensemble member ${ens}..."

	# duplicate input file
	ofilename="${prfx}_${ens}_${fname}"
	cp ${fname} ${ofilename}

	# Calculate perturbation value
	# This calculation involves floating point so the integer arithmetic operator $((....)) can not be used
	ptb_val=$(echo "ptb_val + (ptb_inc * (ens - 1))" | bc )
	
	# perform actual perturbation
	python -u perturb_nc.py ${ptb_var} ${ptb_val} ${ptb_lat} ${ptb_lon} --level=${ptb_lev} --time=${ptb_time} --processors=1 ${ofilename}
done


