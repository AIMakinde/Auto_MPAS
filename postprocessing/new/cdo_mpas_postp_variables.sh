#!/bin/bash

filename="latlon.nc"
prfx1="60_$1_$2-p5_era5"
prfx2="2022"
prfx3="apr"
clnd="2022-04-07,00:00:00,3hour"

# Output tempora resolution
#====================================
# 1 - output same as input step
# 2 - daily output
# 3 - monthly output
# 4 - yearly output
outtstep=1






sorta=(1000 925 850 700 500 250 200)
letters=({a..z})
cnt=0


echo ""
echo "Setting standard calender on the input..."
cdo setcalendar,standard -settaxis,${clnd} ${filename} tmp_${filename}
filename="tmp_${filename}"

echo "extracting variables into its own file.."

#sort all files in accending order of pressure levels
for s in "${sorta[@]}"
do
  if [ "${s}" == "1000" ]
  then
      cdo chname,uzonal_surface,ua -selvar,uzonal_surface ${filename} "ua_mpas${prfx1}-${letters[$cnt]}.nc"
      cdo chname,umeridional_surface,va -selvar,umeridional_surface ${filename} "va_mpas${prfx1}-${letters[$cnt]}.nc"
      cdo chname,temperature_surface,tas -selvar,temperature_surface ${filename} "tas_mpas${prfx1}_${prfx2}.nc"
      cdo chname,temperature_surface,ta -selvar,temperature_surface ${filename} "ta_mpas${prfx1}-${letters[$cnt]}.nc"
      cdo chname,dewpoint_surface,td -selvar,dewpoint_surface ${filename} "td_mpas${prfx1}-${letters[$cnt]}.nc"
      cdo selvar,t2m ${filename} "t2m_mpas${prfx1}_${prfx2}.nc"
      cdo selvar,sst ${filename} "sst_mpas${prfx1}_${prfx2}.nc"
      cdo selvar,cape ${filename} "cape_mpas${prfx1}_${prfx2}.nc"
      cdo chname,q2,q2m -selvar,q2 ${filename} "q2m_mpas${prfx1}_${prfx2}.nc"
      cdo chname,lh,slh -selvar,lh ${filename} "slh_mpas${prfx1}_${prfx2}.nc"

      # create a zero vertical velocity because vertical velocity is zero at surface up to 2m
      cdo mulc,0 -chname,w_${sorta[1]}hPa,wa -selvar,w_${sorta[1]}hPa ${filename} "wa_mpas${prfx1}-${letters[$cnt]}.nc"
	  # create a zero height because is zero at surface (1000hpa)
      cdo mulc,0 -chname,height_${sorta[1]}hPa,hg -selvar,height_${sorta[1]}hPa ${filename} "hg_mpas${prfx1}-${letters[$cnt]}.nc"

  else
      cdo chname,temperature_${s}hPa,ta -selvar,temperature_${s}hPa ${filename} "ta_mpas${prfx1}-${letters[$cnt]}.nc"
      cdo chname,dewpoint_${s}hPa,td -selvar,dewpoint_${s}hPa ${filename} "td_mpas${prfx1}-${letters[$cnt]}.nc"
      cdo chname,uzonal_${s}hPa,ua -selvar,uzonal_${s}hPa ${filename} "ua_mpas${prfx1}-${letters[$cnt]}.nc"
      cdo chname,umeridional_${s}hPa,va -selvar,umeridional_${s}hPa ${filename} "va_mpas${prfx1}-${letters[$cnt]}.nc"
      cdo chname,w_${s}hPa,wa -selvar,w_${s}hPa ${filename} "wa_mpas${prfx1}-${letters[$cnt]}.nc"
      cdo chname,height_${s}hPa,hg -selvar,height_${s}hPa ${filename} "hg_mpas${prfx1}-${letters[$cnt]}.nc"
  fi
  cnt=$(( $cnt + 1 ))
#  break
done

echo ""
echo "merging 3d fields into single file..."
# merge into 3d
cdo merge $( ls ta_mpas${prfx1}-* ) ta_3d_mpas${prfx1}_${prfx2}.nc
cdo merge $( ls td_mpas${prfx1}-* ) td_3d_mpas${prfx1}_${prfx2}.nc
cdo merge $( ls va_mpas${prfx1}-* ) va_3d_mpas${prfx1}_${prfx2}.nc
cdo merge $( ls ua_mpas${prfx1}-* ) ua_3d_mpas${prfx1}_${prfx2}.nc
cdo merge $( ls wa_mpas${prfx1}-* ) wa_3d_mpas${prfx1}_${prfx2}.nc
cdo merge $( ls hg_mpas${prfx1}-* ) hg_3d_mpas${prfx1}_${prfx2}.nc


echo ""
echo "setting pressure axis of 3d fields..."
# set pressure levels
cdo setzaxis,cdompaszaxis.txt ta_3d_mpas${prfx1}_${prfx2}.nc ta_vgrd_mpas${prfx1}_${prfx2}.nc
cdo setzaxis,cdompaszaxis.txt td_3d_mpas${prfx1}_${prfx2}.nc td_vgrd_mpas${prfx1}_${prfx2}.nc
cdo setzaxis,cdompaszaxis.txt va_3d_mpas${prfx1}_${prfx2}.nc va_vgrd_mpas${prfx1}_${prfx2}.nc
cdo setzaxis,cdompaszaxis.txt ua_3d_mpas${prfx1}_${prfx2}.nc ua_vgrd_mpas${prfx1}_${prfx2}.nc
cdo setzaxis,cdompaszaxis.txt wa_3d_mpas${prfx1}_${prfx2}.nc wa_vgrd_mpas${prfx1}_${prfx2}.nc
cdo setzaxis,cdompaszaxis.txt hg_3d_mpas${prfx1}_${prfx2}.nc hg_vgrd_mpas${prfx1}_${prfx2}.nc


if [[ $outtstep -eq 1 ]]
then
    echo ""
    echo "Preparing output..."
    # set time axis and daily mean
    mv ta_vgrd_mpas${prfx1}_${prfx2}.nc ta_hrs_mpas${prfx1}_${prfx2}.nc
    mv td_vgrd_mpas${prfx1}_${prfx2}.nc td_hrs_mpas${prfx1}_${prfx2}.nc
    mv va_vgrd_mpas${prfx1}_${prfx2}.nc va_hrs_mpas${prfx1}_${prfx2}.nc
    mv ua_vgrd_mpas${prfx1}_${prfx2}.nc ua_hrs_mpas${prfx1}_${prfx2}.nc
    mv wa_vgrd_mpas${prfx1}_${prfx2}.nc wa_hrs_mpas${prfx1}_${prfx2}.nc
    mv hg_vgrd_mpas${prfx1}_${prfx2}.nc hg_hrs_mpas${prfx1}_${prfx2}.nc
    mv tas_mpas${prfx1}_${prfx2}.nc tas_hrs_mpas${prfx1}_${prfx2}.nc
    mv t2m_mpas${prfx1}_${prfx2}.nc t2m_hrs_mpas${prfx1}_${prfx2}.nc
    mv q2m_mpas${prfx1}_${prfx2}.nc q2m_hrs_mpas${prfx1}_${prfx2}.nc
    mv slh_mpas${prfx1}_${prfx2}.nc slh_hrs_mpas${prfx1}_${prfx2}.nc
    mv sst_mpas${prfx1}_${prfx2}.nc sst_hrs_mpas${prfx1}_${prfx2}.nc
    mv cape_mpas${prfx1}_${prfx2}.nc cape_hrs_mpas${prfx1}_${prfx2}.nc
    mv pas_mpas${prfx1}_${prfx2}.nc pas_hrs_mpas${prfx1}_${prfx2}.nc
elif [[ $outtstep -eq 2 ]]
then
    echo ""
    echo "calculating daily mean..."
    # set time axis and daily mean
    cdo daymean  ta_vgrd_mpas${prfx1}_${prfx2}.nc ta_day_mpas${prfx1}_${prfx2}.nc
    cdo daymean  td_vgrd_mpas${prfx1}_${prfx2}.nc td_day_mpas${prfx1}_${prfx2}.nc
    cdo daymean  va_vgrd_mpas${prfx1}_${prfx2}.nc va_day_mpas${prfx1}_${prfx2}.nc
    cdo daymean ua_vgrd_mpas${prfx1}_${prfx2}.nc ua_day_mpas${prfx1}_${prfx2}.nc
    cdo daymean wa_vgrd_mpas${prfx1}_${prfx2}.nc wa_day_mpas${prfx1}_${prfx2}.nc
    cdo daymean hg_vgrd_mpas${prfx1}_${prfx2}.nc hg_day_mpas${prfx1}_${prfx2}.nc
    cdo daymean tas_mpas${prfx1}_${prfx2}.nc tas_day_mpas${prfx1}_${prfx2}.nc
    cdo daymean t2m_mpas${prfx1}_${prfx2}.nc t2m_day_mpas${prfx1}_${prfx2}.nc
    cdo daymean q2m_mpas${prfx1}_${prfx2}.nc q2m_day_mpas${prfx1}_${prfx2}.nc
    cdo daymean slh_mpas${prfx1}_${prfx2}.nc slh_day_mpas${prfx1}_${prfx2}.nc
    cdo daymean sst_mpas${prfx1}_${prfx2}.nc sst_day_mpas${prfx1}_${prfx2}.nc
    cdo daymean cape_mpas${prfx1}_${prfx2}.nc cape_day_mpas${prfx1}_${prfx2}.nc
    cdo daymean pas_mpas${prfx1}_${prfx2}.nc pas_day_mpas${prfx1}_${prfx2}.nc

elif [[ $outtstep -eq 3 ]]
then
    echo ""
    echo "calculating monthly mean..."
    # monthly average
    cdo monmean ta_vgrd_mpas${prfx1}_${prfx2}.nc ta_mon_mpas${prfx1}_${prfx2}.nc
    cdo monmean td_vgrd_mpas${prfx1}_${prfx2}.nc td_mon_mpas${prfx1}_${prfx2}.nc
    cdo monmean va_vgrd_mpas${prfx1}_${prfx2}.nc va_mon_mpas${prfx1}_${prfx2}.nc
    cdo monmean va_vgrd_mpas${prfx1}_${prfx2}.nc va_mon_mpas${prfx1}_${prfx2}.nc
    cdo monmean ua_vgrd_mpas${prfx1}_${prfx2}.nc ua_mon_mpas${prfx1}_${prfx2}.nc
    cdo monmean wa_vgrd_mpas${prfx1}_${prfx2}.nc wa_mon_mpas${prfx1}_${prfx2}.nc
    cdo monmean hg_vgrd_mpas${prfx1}_${prfx2}.nc hg_mon_mpas${prfx1}_${prfx2}.nc
    cdo monmean tas_mpas${prfx1}_${prfx2}.nc tas_mon_mpas${prfx1}_${prfx2}.nc
    cdo monmean t2m_mpas${prfx1}_${prfx2}.nc t2m_mon_mpas${prfx1}_${prfx2}.nc
    cdo monmean q2m_mpas${prfx1}_${prfx2}.nc q2m_mon_mpas${prfx1}_${prfx2}.nc
    cdo monmean slh_mpas${prfx1}_${prfx2}.nc slh_mon_mpas${prfx1}_${prfx2}.nc
    cdo monmean sst_mpas${prfx1}_${prfx2}.nc sst_mon_mpas${prfx1}_${prfx2}.nc
    cdo monmean cape_mpas${prfx1}_${prfx2}.nc cape_mon_mpas${prfx1}_${prfx2}.nc
    cdo monmean pas_mpas${prfx1}_${prfx2}.nc pas_mon_mpas${prfx1}_${prfx2}.nc

elif [[ $outtstep -eq 4 ]]
then
    echo ""
    echo "calculating monthly mean..."
    # monthly average
    cdo yearmean ta_vgrd_mpas${prfx1}_${prfx2}.nc ta_yrs_mpas${prfx1}_${prfx2}.nc
    cdo yearmean td_vgrd_mpas${prfx1}_${prfx2}.nc td_yrs_mpas${prfx1}_${prfx2}.nc
    cdo yearmean va_vgrd_mpas${prfx1}_${prfx2}.nc va_yrs_mpas${prfx1}_${prfx2}.nc
    cdo yearmean ua_vgrd_mpas${prfx1}_${prfx2}.nc ua_yrs_mpas${prfx1}_${prfx2}.nc
    cdo yearmean wa_vgrd_mpas${prfx1}_${prfx2}.nc wa_yrs_mpas${prfx1}_${prfx2}.nc
    cdo yearmean hg_vgrd_mpas${prfx1}_${prfx2}.nc hg_yrs_mpas${prfx1}_${prfx2}.nc
    cdo yearmean tas_mpas${prfx1}_${prfx2}.nc tas_yrs_mpas${prfx1}_${prfx2}.nc
    cdo yearmean t2m_mpas${prfx1}_${prfx2}.nc t2m_yrs_mpas${prfx1}_${prfx2}.nc
    cdo yearmean q2m_mpas${prfx1}_${prfx2}.nc q2m_yrs_mpas${prfx1}_${prfx2}.nc
    cdo yearmean slh_mpas${prfx1}_${prfx2}.nc slh_yrs_mpas${prfx1}_${prfx2}.nc
    cdo yearmean sst_mpas${prfx1}_${prfx2}.nc sst_yrs_mpas${prfx1}_${prfx2}.nc
    cdo yearmean cape_mpas${prfx1}_${prfx2}.nc cape_yrs_mpas${prfx1}_${prfx2}.nc
    cdo yearmean pas_mpas${prfx1}_${prfx2}.nc pas_yrs_mpas${prfx1}_${prfx2}.nc
fi

echo ""
echo "tiding things up ..."
## tidy up
rm *_mpas${prfx1}-*
rm *_3d_mpas${prfx1}_${prfx2}.nc
rm *_vgrd_mpas${prfx1}_${prfx2}.nc

echo ""
echo "done."
