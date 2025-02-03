#!/bin/bash

fname="era5_prslv_202204070000.netcdf"
prfx="ensbl"
ptb_lev=15
ptb_time=0
ptb_var="t"
nensemble=10


for ens in $( seq 1 1 $nensemble );
do
	echo "generating ensemble member ${ens}..."

	# duplicate input file
	ofilename="${prfx}_${ens}_${fname}"
	cp ${fname} ${ofilename}

	echo "Updating perturbation target to target_locs.perturb${ens}"
	cp target_locs.perturb${ens} target_locs.perturb

	# perform actual perturbation
	python -u perturb_nc.py ${ptb_var} --level=${ptb_lev} --time=${ptb_time} --processors=1 ${ofilename}
done


