#!/bin/bash



# ensure the del directory is created if not exist
mkdir -p del

for d in 202204{05..19}
do
	# First rename the downloade sfc files
	mv era5_sfc_${d}.netcdf era5_sfc_${d}.zip

	# Now unzip the downloaded files
	unzip era5_sfc_${d}.zip
	
	# You get two files afer unzip, rename the instant one
	mv data_stream-oper_stepType-instant.nc era5_sfc_${d}.nc

	# Delete the accumulated one
	mv data_stream-oper_stepType-accum.nc ./del
done
