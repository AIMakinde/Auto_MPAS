#!/bin/bash



# ensure the del directory is created if not exist
mkdir -p coolac
mkdir -p warmac

for d in 202204{05..19}
do
	# First configure the filter for cooling
	cp config1.filter config.filter

	# Perform the filtering
	python -u agulhas_filter_nc.py era5_sfc_${d}.nc

	# Move result to appropriate folder
	mv mod_era5_sfc_${d}.nc ./coolac

	# Seconf configure the filter for warming
	cp config2.filter config.filter

	# Perform the filtering
        python -u agulhas_filter_nc.py era5_sfc_${d}.nc

        # Move result to appropriate folder
        mv mod_era5_sfc_${d}.nc ./warmac

done
