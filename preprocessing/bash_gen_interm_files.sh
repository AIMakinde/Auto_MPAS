#!/bin/bash

# Activate conda enviroment
#source /apps/chpc/bio/anaconda3-2020.02/etc/profile.d/conda.sh
#conda activate mpasenv

cnt=0
# Generate the Pressure intermidiate files
for ensbl in `ls ./raw/ensbl_*_era5_prslv_*.netcdf`;
do
	cnt=$(( cnt + 1 ))
	cp include_var.interm.plv include_var.interm
	python -u gen_interm_files.py -o="ENSB${cnt}" -p=2 -cg $ensbl
done

# Generate the surface intermidiate files
#cp include_var.interm.sfc include_var.interm
#python -u gen_interm_files.py -o="SST" -p=2 -cg ./raw/era5_sfc_202204*.netcdf
