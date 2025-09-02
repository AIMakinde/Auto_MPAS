#!/bin/bash
# Script to compute equivalent potential temperature (theta_e) using CDO
# Input files:
#   ta_fname(netcdf)  : Temperature field (4D: time, level, lat, lon) in Kelvin
#   td_fname(netcdf) : Dew point temperature field (4D: time, level, lat, lon) in Kelvin
#
# Pressure levels are fixed as: 1000, 925, 850, 700, 500, 250, 200 hPa.
# It is assumed that the order of levels in T.nc and Td.nc corresponds to these values.
#
# Output:
#   theta_e.nc : Equivalent potential temperature

prfx1="$1"
prfx2="$2"
ta_fname="ta_hrs_mpas60_${prfx1}_${prfx2}-p5_era5_2022.nc"
td_fname="td_hrs_mpas60_${prfx1}_${prfx2}-p5_era5_2022.nc"
# Define the fixed pressure levels in hPa (order must correspond to the levels in ta_fname/td_fname)
PRESSURE=(1000 925 850 700 500 250 200)

# Check for input files
for f in "$ta_fname" "$td_fname"; do
    if [ ! -f "$f" ]; then
       echo "Error: $f not found!"
       exit 1
    fi
done

echo "Merging Ta and Td into a single file..."
# Merge temperature and dew point fields (assumed to share same dimensions)
cdo merge $ta_fname $td_fname tmp_TTd.nc

NUM_LEVELS=${#PRESSURE[@]}

# Create a constant pressure field for each level using a template from T.nc.
# We use 'sellevidx' (select by index) to extract a level from T.nc,
# then 'setconst' to create a field with the desired constant pressure value,
# and finally 'chname' to rename the variable (from T to p).
echo "Creating constant pressure fields for each level..."
for (( i=0; i<$NUM_LEVELS; i++ )); do
    level_index=$((i+1))
    p_value=${PRESSURE[i]}
    echo "  Level index $level_index: setting pressure = $p_value hPa"
    # Extract level index from T.nc as a template (the actual values are not used)
    cdo sellevidx,${level_index},${level_index} $ta_fname tmp_template.nc
    # Replace the field with a constant value equal to p_value and rename the variable
    cdo chname,ta,pa -setrtoc,-5000.0,5000.0,${p_value} tmp_template.nc tmp_p_${level_index}.nc
done

echo "Merging individual pressure fields along the level dimension..."
# Merge all individual level pressure files into one 4D file
cdo merge tmp_p_*.nc tmp_p.nc

echo "Merging pressure (p) with Ta and Td fields..."
# Merge the constant pressure file with the combined T and Td file.
# The resulting file, tmp_all.nc, now contains T, T_d, and p.
cdo merge tmp_TTd.nc tmp_p.nc tmp_all.nc

# Now compute equivalent potential temperature.
# The following steps use a simplified approximation:
#
#   1) Compute saturation vapor pressure (e_s) from dew point temperature T_d:
#         e_s = 6.112 * exp(17.67*(T_d-273.15)/((T_d-273.15)+243.5))
#
#   2) Compute mixing ratio (r):
#         r = 0.622 * e_s / (p - e_s)
#
#   3) Compute potential temperature (theta):
#         theta = T * (1000/p)^0.2857
#
#   4) Compute equivalent potential temperature (theta_e):
#         theta_e = theta * exp((2.5e6 * r)/(1004*T))
echo "Calculating saturation vapor pressure (e_s)..."
cdo expr,'es=6.112*exp(17.67*(td-273.15)/((td-273.15)+243.5))' tmp_all.nc tmp_es.nc
cdo merge tmp_es.nc tmp_all.nc tmp_all_es.nc

echo "Calculating mixing ratio (r)..."
cdo expr,'r=0.622*es/(pa - es)' tmp_all_es.nc tmp_r.nc

echo "Calculating potential temperature (theta)..."
cdo expr,'theta=ta*(1000/pa)^0.2857' tmp_all_es.nc tmp_theta.nc

echo "Merging theta and r fields..."
cdo merge tmp_theta.nc tmp_r.nc tmp_all_es.nc tmp_all_calc.nc

echo "Calculating equivalent potential temperature (theta_e)..."
cdo expr,'thetae=theta*exp(2500000*r/(1004*ta))' tmp_all_calc.nc thetae_hrs_mpas60_${prfx1}_${prfx2}-p5_era5_2022.nc

echo "Equivalent potential temperature calculation complete. Output written to thetae_hrs_mpas60_${prfx1}_${prfx2}-p5_era5_2022.nc"

# Clean up temporary files
rm -f tmp_TTd.nc tmp_template.nc tmp_const.nc tmp_p_*.nc tmp_p.nc tmp_all*.nc tmp_es.nc tmp_r.nc tmp_theta.nc tmp_all_calc.nc
