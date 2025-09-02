
prfx1="$1"
prfx2="$2"
subname="60_${prfx1}_${prfx2}-p5_era5"
namesfx="2022"
cdo -O selday,8/14 -merge ua_hrs_mpas${subname}_${namesfx}.nc va_hrs_mpas${subname}_${namesfx}.nc wa_hrs_mpas${subname}_${namesfx}.nc tas_hrs_mpas${subname}_${namesfx}.nc t2m_hrs_mpas${subname}_${namesfx}.nc q2m_hrs_mpas${subname}_${namesfx}.nc sst_hrs_mpas${subname}_${namesfx}.nc slh_hrs_mpas${subname}_${namesfx}.nc zg_hrs_mpas${subname}_${namesfx}.nc hg_hrs_mpas${subname}_${namesfx}.nc prc_hrs_mpas${subname}_${namesfx}.nc td_hrs_mpas${subname}_${namesfx}.nc cape_hrs_mpas${subname}_${namesfx}.nc thetae_hrs_mpas${subname}_${namesfx}.nc mpas${subname}_3hrs_apr2022.nc
# cdo -O selday,8/14 -merge ua_hrs_mpas60_cfsr_${namesfx}.nc va_hrs_mpas60_cfsr_${namesfx}.nc wa_hrs_mpas60_cfsr_${namesfx}.nc tas_hrs_mpas60_cfsr_${namesfx}.nc t2m_hrs_mpas60_cfsr_${namesfx}.nc q2m_hrs_mpas60_cfsr_${namesfx}.nc sst_hrs_mpas60_cfsr_${namesfx}.nc slh_hrs_mpas60_cfsr_${namesfx}.nc gz_hrs_mpas60_cfsr_${namesfx}.nc hg_hrs_mpas60_cfsr_${namesfx}.nc prc_mpas60_cfsr_3hrs_${namesfx}.nc mpas60_cfsr_3hrs_apr2022.nc
