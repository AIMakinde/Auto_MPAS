#!/bin/bash


filename="latlon.nc"
prfx1="60_$1_$2-p5_era5"
prfx2="2022"
prfx3="hrs"
outcalender="2022-04-07,09:00:00,3hours"
tstep=3  # 3 hourly dataset
total_tsteps=89
ystart=2022
yend=2022


# Use Bucket counter if present
#====================================
# 1 = compute rainfall update using i_rainc and i_rainnc
# 0 = no i_rainc and i_rainnc in latlon.nc
doBucket=0


# Output tempora resolution
#====================================
# 1 - output same as input step
# 2 - daily output
# 3 - monthly output
# 4 - yearly output
outtstep=1









mult=$(( 24 / tstep ))
echo "$mult timesteps per day"

isfirst=1
liststeps1=""
liststeps2=""
echo "retrieving steps for first and last day of the month.."

#======================================================================================
# For outputs timesteps same as input
#======================================================================================
if [[ $outtstep -eq 1 ]]
then
	cmnt=0
	mult=1
	isfirst=1
	thetotal=$(( total_tsteps - 1))
	while [[ $step2 -le $thetotal ]]
	do
		cmnt=$(( cmnt + 1))
		if [ ${isfirst} -ge 1 ]
		then
			step1=1  #first timestep
			step2=2  # last timestep
		else
			step1=$step2  #first timestep
			step2=$(( step2 + 1))  #last timestep
		fi
		
		liststeps1="${liststeps1},${step1}"
		liststeps2="${liststeps2},${step2}"

		isfirst=0
	done


#======================================================================================
# For daily outputs
#======================================================================================
elif [[ $outtstep -eq 2 ]]
then
	cmnt=0
	while [ $step2 -le $total_tsteps ]
	do
		cmnt=$(( cmnt + 1))
		if [ ${isfirst} -ge 1 ]
		then
			step1=1  #first timestep
			step2=$(( step1 + (cmnt * mult ) ))  # last timestep
		else
			step1=$step2  #first timestep
			step2=$(( step2 + ( cmnt * mult ) ))  #last timestep
		fi
		
		liststeps1="${liststeps1},${step1}"
		liststeps2="${liststeps2},${step2}"

		isfirst=0
	done

#======================================================================================
# For monthly outputs
#======================================================================================
elif [[ $outtstep -eq 3 ]] 
then
	for yr in $( seq -w $ystart $yend )
	do
		for mn in {1..12}
		do
			# Get total days in the month
			cmnt=$( cal $mn $yr | awk 'NF {DAYS = $NF}; END {print DAYS}' )
			if [ ${isfirst} -ge 1 ]
			then
				step1=1  #first timestep of the month
				step2=$(( cmnt * mult ))  # last timestep of the month
			else
				step1=$(( step1 + ( cmnt * mult ) ))  #first timestep of the month
				step2=$(( step2 + ( cmnt * mult ) ))  #last timestep of the month
			fi
			
			liststeps1="${liststeps1},${step1}"
			liststeps2="${liststeps2},${step2}"
			isfirst=0
		done
	done

#======================================================================================
# For yearly outputs
#======================================================================================
elif [[ $outtstep -eq 4 ]]
then
	echo "yearly section not done yet"
	for yr in $( seq -w $ystart $yend )
	do
		echo "Not implemented yet"
		exit 1
	done
fi


echo ""
echo "extracting variables into its own file..."

# Do the deaccumulation (i.e subtraction) before asigning taxis
cdo -selvar,rainc ${filename} rainc_mpas${prfx1}_${prfx2}.nc
cdo -selvar,rainnc ${filename} rainnc_mpas${prfx1}_${prfx2}.nc

if [[ $doBucket -ge 1 ]]
then
	cdo -selvar,i_rainc ${filename} irainc_mpas${prfx1}_${prfx2}.nc
	cdo -selvar,i_rainnc ${filename} irainnc_mpas${prfx1}_${prfx2}.nc

	# calculate totatl precipitation
	echo "calculating totatl precipitation..."
	# multiply irain by 100
	cdo mulc,100 irainc_mpas${prfx1}_${prfx2}.nc irainc_mpas${prfx1}_total_${prfx2}.nc
	cdo mulc,100 irainnc_mpas${prfx1}_${prfx2}.nc irainnc_mpas${prfx1}_total_${prfx2}.nc

	# add all together
	cdo -chname,rainc,prc -add rainc_mpas${prfx1}_${prfx2}.nc irainc_mpas${prfx1}_total_${prfx2}.nc rainnc_mpas${prfx1}_${prfx2}.nc irainnc_mpas${prfx1}_total_${prfx2}.nc totalprc_mpas${prfx1}_${prfx2}.nc
else
	# add all together
	cdo -chname,rainc,prc -add rainc_mpas${prfx1}_${prfx2}.nc rainnc_mpas${prfx1}_${prfx2}.nc totalprc_mpas${prfx1}_${prfx2}.nc

fi


echo "extracting time steps ..."
# extract all first and last days of the each month
echo ${liststeps1}
cdo -seltimestep${liststeps1} totalprc_mpas${prfx1}_${prfx2}.nc totalprc_steps1_mpas${prfx1}_${prfx2}.nc 
echo ${liststeps1}
echo ""
cdo -seltimestep${liststeps2} totalprc_mpas${prfx1}_${prfx2}.nc totalprc_steps2_mpas${prfx1}_${prfx2}.nc 
echo ${liststeps2}


# deaccumulate
echo "de-accumulating precipitation..."
cdo -sub totalprc_steps2_mpas${prfx1}_${prfx2}.nc totalprc_steps1_mpas${prfx1}_${prfx2}.nc prc_mpas${prfx1}_${prfx2}.nc


echo "setting calendar..."
# set calendar
cdo -setcalendar,standard -settaxis,${outcalender}  prc_mpas${prfx1}_${prfx2}.nc prc_mpas${prfx1}_${prfx2}_deacc.nc


echo "padding the missing data to position zero..."
cdo -setrtomiss,-100,2000 -shifttime,-${tstep}hours -seltimestep,1 prc_mpas${prfx1}_${prfx2}_deacc.nc prc_mpas${prfx1}_${prfx2}_padded.nc
cdo mergetime prc_mpas${prfx1}_${prfx2}_deacc.nc prc_mpas${prfx1}_${prfx2}_padded.nc prc_${prfx3}_mpas${prfx1}_${prfx2}.nc

#echo ""
echo "tiding things up ..."
## tidy up
rm rain*_mpas${prfx1}_${prfx2}.nc 
rm rain*_mon_mpas${prfx1}_${prfx2}.nc
rm irain*_mon_mpas${prfx1}_${prfx2}.nc
rm tprc_${prfx3}_mpas${prfx1}_${prfx2}.nc
rm prc_mpas${prfx1}_${prfx2}_deacc.nc
rm prc_mpas${prfx1}_${prfx2}_padded.nc


echo ""
echo "done."
