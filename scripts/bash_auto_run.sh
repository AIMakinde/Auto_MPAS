#!/bin/bash

# ==== Forcing dataset section ===============

dtpath="data/era5/for_agulhas/ctrl"				## where do you want all dataset to be downloaded to?
prsdwnstartdatetime=202204050000		## start datetime for downloading pressure level forcing data
prsdwnenddatetime=202204200000  		## Note: at least more than 6 days ahead of prsdwnstartdatetime, to avoid ungrib error
sfcdwnstartdatetime=202204050000		## Start datetime for downloading surface forcing dataset
sfcdwnenddatetime=202204200000			## End datatime for downloading surface forcing dataset
singlemultiyears=1				## Option 0 - download forcing data year by year so that each year have its own directory. It is going to be a short year-to-year simulation
						## Option 1 - download forcing data for all the years so that all the years reside in just one directory. It will be used for long/multi-year simulation


# ===== Ungrib section ========================

prsungrbstartdatetime=2022-04-05_00:00:00  	## Note: make sure its thesame as 'prsdwnstartdatetime' and formatted as it is (using '_' and ':" as date and time separator) to avoid ungrib error
prsungrbenddatetime=2022-04-20_00:00:00		## Note: at most the end datetime should be 18 hrs less than 'prsdwnenddatetime'
sfcungrbstartdatetime=2022-04-05_00:00:00	## Note: Should be less than or equal to 'prsungrbstartdatetime'
sfcungrbenddatetime=2022-04-20_00:00:00		## Note: at most, it should be less than or equal to 'sfcdwnenddatetime'
manyyearsungrib=1				## Option 0 - Ungrib forcing data year by year.
						## Option 1 - Ungrib forcing data all at once, starting from 'sfcungrbstartdatetime' to 'sfcungrbenddatetime'

# ========= Simulation settings section ========
simstartdate=2022-04-07_00:00:00		## Note: Should be thesame as the 'prsungrbstartdatetime'
simenddate=2022-04-17_00:00:00			## Can be any datetime you want the simulation to stop

rundir="ctrl_sim/ctrl"			## Name of the model directory to create or over write. Note model excutables, files and output will be copied to this directory
rsltn="60km"					## What resolution do you want to run? Remember to qoute it as string and include the unit
lowRsltn=03      				## Note: the value is not qouted (i.e. not "" or ''). For variable resolution, set to the lowest resolution. For uniform resolution, use thesame value as 'rsltn'
meshdir="meshes/6003km/regrid_sa"				## Where is location of the mesh for the particular resolutin you wish to run?
ncores=576					## How many processors do which to use. Note: make sure a partitioning file for the number processors you have choosen is avaialable in the 'meshdir'
LOGFILE="log.era5-ctrl_ctrl_6003km"		## This bash script generates a log file. What do you wish to name the logfile?

# ======== Simulation Switches =============
# Option 0 - do not skip, run the process
# Option 1 - do not run, skip the process

skipdwn=1
skipung=1
skipinit=0
skipatmos=0

# ======== Dataset Options =============
# Option 0 - Download forcing data from CFSR
# Option 1 - Download forcing data from ERA5

datasrc=1  ## Download CSFR
jobprfx=""
grdprfx="x"
metprfx="PRES"
sfcprfx="SST"



#########################################################################################
#
# Please do not modify any thing beyond this point. Any further alteration may impact or
# stop this script, the model setup and the model from running.
# Except you know the implication of what you are about to change and are sure
# you really want to do so.
#
########################################################################################


bpath="$( pwd )"
yr="${prsdwnstartdatetime:0:4}"


# Remove and create the log file
[ -f ${LOGFILE} ] && rm ${LOGFILE}
touch ${LOGFILE}

{ # starting block

echo "starting mpas automation..."

#=========================================================#
# Dowload dataset
#=========================================================#

if [ ${skipdwn} -le 0 ]
then

	echo "Downloading datasets...."

	# create data folder if not exist
	mkdir -p ${dtpath}/

	# copy script to download

	if [ ${datasrc} == "0" ];
	then
		cp rdams_client.py ./${dtpath}/
		cp rdams_helper.py ./${dtpath}/
		cp cfsr_dwn_prslev.py ./${dtpath}/
		cp cfsr_dwn_sfc.py ./${dtpath}/
		cp rdams_token.txt ./${dtpath}/
		cp bash_dwn_cfsr.sh ./${dtpath}/
	else
		cp bash_dwn_era5.sh ./${dtpath}/
		cp era5_dwn_prslev.py ./${dtpath}/
		cp era5_dwn_sfc.py ./${dtpath}/
	fi

	# change working directory to download folder
	cd "${bpath}/${dtpath}/"

	prsd1="prsstartdate=${prsdwnstartdatetime}"
	prsd2="prsenddate=${prsdwnenddatetime}"
	sfcd1="sfcstartdate=${sfcdwnstartdatetime}"
	sfcd2="sfcenddate=${sfcdwnenddatetime}"
	sfcd3="singlemultiyears=${singlemultiyears}"

	if [ ${datasrc} == "0" ];
	then
		sed -i "3s|.*|${prsd1}|" bash_dwn_cfsr.sh
		sed -i "4s|.*|${prsd2}|" bash_dwn_cfsr.sh
		sed -i "5s|.*|${sfcd1}|" bash_dwn_cfsr.sh
		sed -i "6s|.*|${sfcd2}|" bash_dwn_cfsr.sh
		sed -i "7s|.*|${sfcd3}|" bash_dwn_cfsr.sh
	else
		sed -i "3s|.*|${prsd1}|" bash_dwn_era5.sh
		sed -i "4s|.*|${prsd2}|" bash_dwn_era5.sh
		sed -i "5s|.*|${sfcd1}|" bash_dwn_era5.sh
		sed -i "6s|.*|${sfcd2}|" bash_dwn_era5.sh
		sed -i "8s|.*|${sfcd3}|" bash_dwn_era5.sh
	fi

	# run download script
	if [ ${datasrc} == "0" ];
	then
		./bash_dwn_cfsr.sh
	else
		./bash_dwn_era5.sh
	fi
	
	cd "${bpath}/"
fi




#=========================================================#
# Ungrib intermediate files
#=========================================================#

if [ ${skipung} -le 0 ]
then
	echo ""
	echo ""
	echo "starting ungrib for intermediate files..."

	# create wps utils if not exist
	[ ! -d "${bpath}/utils/wpsprd/" ] && ./setup_mpas_utils_workdir_update.sh

	# copy namelist files to wpsprd folder for ungrib
	echo "copying namelist files to wpsrd directory..."
	cp namelist.wps* ./utils/wpsprd/
	cp Vtable.* ./utils/wpsprd/
	cp bash_ung*.sh ./utils/wpsprd/
	cp run_ungrib.qsub ./utils/wpsprd/

	# modify run_ungrib.qsub
	echo "modifying run_ungrib.qsub for ungrib..."
	upath="${bpath}/utils/wpsprd"
	cd "${upath}/"

	rqsb="cd '${upath}'"
	rqsb2="#PBS -N ${yr}_Ungrib"
	sed -i "8s|.*|${rqsb2}|" run_ungrib.qsub
	sed -i "16s|.*|${rqsb}|" run_ungrib.qsub

	bsu1="datapath='${bpath}/${dtpath}'"
	bsu2="prs_startdate='${prsungrbstartdatetime}'"
	bsu3="prs_enddate='${prsungrbenddatetime}'"
	bsu4="sfc_startdate='${sfcungrbstartdatetime}'"
	bsu5="sfc_enddate='${sfcungrbenddatetime}'"
	bsu6="multiyearsungrib=${manyyearsungrib}"

	if [ ${datasrc} == "0" ];
	then
		echo "modifying bash_ung_cfsr.sh for the current run..."
		sed -i "3s|.*|${bsu1}|" bash_ung_cfsr.sh
		sed -i "4s|.*|${bsu2}|" bash_ung_cfsr.sh
		sed -i "5s|.*|${bsu3}|" bash_ung_cfsr.sh
		sed -i "6s|.*|${bsu4}|" bash_ung_cfsr.sh
		sed -i "7s|.*|${bsu5}|" bash_ung_cfsr.sh
		sed -i "8s|.*|${bsu6}|" bash_ung_cfsr.sh

		ln -sf bash_ung_cfsr.sh bash_ung.sh
	else
		echo "modifying bash_ung_era5.sh for the current run..."
		sed -i "3s|.*|${bsu1}|" bash_ung_era5.sh
		sed -i "4s|.*|${bsu2}|" bash_ung_era5.sh
		sed -i "5s|.*|${bsu3}|" bash_ung_era5.sh
		sed -i "6s|.*|${bsu4}|" bash_ung_era5.sh
		sed -i "7s|.*|${bsu5}|" bash_ung_era5.sh
		sed -i "8s|.*|${bsu6}|" bash_ung_era5.sh

		ln -sf bash_ung_era5.sh bash_ung.sh
	fi

	jobsig="ungrib.finished"
	rm "${jobsig}"
	
	# run ungrib
	echo "submitting run_ungrib.qsub"
	qsub run_ungrib.qsub

	echo "waiting for ungrib to finish...."
	# wait for ungrib to finish
	while [ ! -f "${jobsig}" ]
	do
		sleep 5m # sleep for 5 minutes
	done
	
	echo "ungrib has finished"
	cd "${bpath}/"
fi




#=======================================================================#
# Run MPAS Init
#=======================================================================#

if [ ${skipinit} -le 0 ]
then
	echo ""
	echo ""
	echo "running mpas initialization..."

	# create mpas run folder if not exist
	if [ ! -d "${rundir}" ]
	then
		wdir="workdir='${rundir}'"
		sed -i "3s|.*|${wdir}|" setup_mpas8_workdir.sh

		./setup_mpas8_workdir.sh
	fi

	# copy namelist and other files
	cp namelist.init_atmosphere_met ./${rundir}/mpas_init/
	cp namelist.init_atmosphere_sst ./${rundir}/mpas_init/
	cp namelist.init_atmosphere_static ./${rundir}/mpas_init/
	cp streams.init_atmosphere_met ./${rundir}/mpas_init/
	cp streams.init_atmosphere_sst ./${rundir}/mpas_init/
	cp streams.init_atmosphere_static ./${rundir}/mpas_init/
	cp run_mpas_auto_init.qsub ./${rundir}/mpas_init/
	cp bash_init.sh ./${rundir}/mpas_init/
	cp setupMPAS ./${rundir}/mpas_init/

	cd ./${rundir}/mpas_init/

	ln -sf ${bpath}/${meshdir}/${grdprfx}*.grid.nc .
	ln -sf ${bpath}/${meshdir}/${grdprfx}*.graph.info .


	# modify namelists
	str1a="    config_geog_data_path = '${bpath}/${rundir}/GEOG/'"
	str1b="    config_met_prefix = '${metprfx}'"
	str1c="    config_sfc_prefix = '${sfcprfx}'"
	tmp=$( ls ${bpath}/${meshdir}/${grdprfx}*.grid.nc )  # get fullname of grid file e.g ~/x6.999426.grid.nc
	fname=$(basename "${tmp}" )  # extract filename only
	parts=( ${fname//./ } )     # split the name by "."
	str1d="    config_block_decomp_file_prefix = '${parts[0]}.${parts[1]}.graph.info.part.'"
	sed -i "19s|.*|${str1a}|" namelist.init_atmosphere_met
	sed -i "56s|.*|${str1d}|" namelist.init_atmosphere_met
	sed -i "20s|.*|${str1b}|" namelist.init_atmosphere_met
	sed -i "21s|.*|${str1c}|" namelist.init_atmosphere_met
	
	sed -i "20s|.*|${str1a}|" namelist.init_atmosphere_sst
	sed -i "57s|.*|${str1d}|" namelist.init_atmosphere_sst
	sed -i "21s|.*|${str1b}|" namelist.init_atmosphere_sst
	sed -i "22s|.*|${str1c}|" namelist.init_atmosphere_sst

	sed -i "19s|.*|${str1a}|" namelist.init_atmosphere_static
	sed -i "56s|.*|${str1d}|" namelist.init_atmosphere_static
	sed -i "20s|.*|${str1b}|" namelist.init_atmosphere_static
	sed -i "21s|.*|${str1c}|" namelist.init_atmosphere_static

	# modify streams files
	str2="                  filename_template='${parts[0]}.${parts[1]}.grid.nc'"
	str3="                  filename_template='${parts[0]}.${parts[1]}.static.nc'"
	str4="                  filename_template='${parts[0]}.${parts[1]}.init.nc'"
	str5="                  filename_template='${parts[0]}.${parts[1]}.sfc_update.nc'"
	sed -i "4s|.*|${str3}|" streams.init_atmosphere_met
	sed -i "9s|.*|${str4}|" streams.init_atmosphere_met
	sed -i "16s|.*|${str5}|" streams.init_atmosphere_met
	sed -i "4s|.*|${str3}|" streams.init_atmosphere_sst
	sed -i "9s|.*|${str4}|" streams.init_atmosphere_sst
	sed -i "15s|.*|${str5}|" streams.init_atmosphere_sst
	sed -i "4s|.*|${str2}|" streams.init_atmosphere_static
	sed -i "9s|.*|${str3}|" streams.init_atmosphere_static
	sed -i "15s|.*|${str5}|" streams.init_atmosphere_static

	# modify run qsub
	dstr6b="CS=${rundir}"
	dstr6a="SIMDIR=${bpath}"
	dstr6c="#PBS -N ${yr}_${rsltn}-Init"
	sed -i "7s|.*|${dstr6c}|" run_mpas_auto_init.qsub
	sed -i "23s|.*|${dstr6b}|" run_mpas_auto_init.qsub
	sed -i "24s|.*|${dstr6a}|" run_mpas_auto_init.qsub


	# modify bash file
	dstr1="startyr='${simstartdate:0:4}'"
	dstr2="endyr='${simenddate:0:4}'"
	dstr3="startdate='${simstartdate:5:14}'  # mon day hr min sec"
	dstr4="enddate='${simenddate:5:14}'  # mon day hr min sec"
	dstr5="datapath='${bpath}/${dtpath}'"
	dstr5b="rsltn='${rsltn}'"
	dstr5c="jobprfx='${jobprfx}'"
	dstr5d="grdprfx='${grdprfx}'"
	dstr5e="metprfx='${metprfx}'"
	dstr5f="sfcprfx='${sfcprfx}'"

	sed -i "3s|.*|${dstr1}|" bash_init.sh
	sed -i "4s|.*|${dstr2}|" bash_init.sh
	sed -i "5s|.*|${dstr3}|" bash_init.sh
	sed -i "6s|.*|${dstr4}|" bash_init.sh
	sed -i "7s|.*|${dstr5}|" bash_init.sh
	sed -i "11s|.*|${dstr5b}|" bash_init.sh
	sed -i "13s|.*|${dstr5c}|" bash_init.sh
	sed -i "14s|.*|${dstr5d}|" bash_init.sh
	sed -i "15s|.*|${dstr5e}|" bash_init.sh
	sed -i "16s|.*|${dstr5f}|" bash_init.sh


	# run bash script
	bash bash_init.sh


	cd "${bpath}/"
fi




#=======================================================================#
# Run MPAS Atmos
#=======================================================================#

if [ ${skipatmos} -le 0 ]
then
	echo ""
	echo ""
	echo "running mpas model intergration..."

	# create mpas run folder if not exist
        if [ ! -d "${rundir}" ]
        then
                wdir="workdir='${rundir}'"
                sed -i "3s|.*|${wdir}|" setup_mpas8_workdir.sh

                ./setup_mpas8_workdir.sh
        fi

	# copy namelist and other files
	cp namelist.atmosphere ./${rundir}/mpas_atmos/namelist.atmosphere_org
	cp stream_list.atmosphere.diagnostics ./${rundir}/mpas_atmos/
	cp stream_list.atmosphere.output ./${rundir}/mpas_atmos/
	cp stream_list.atmosphere.surface ./${rundir}/mpas_atmos/
	cp streams.atmosphere ./${rundir}/mpas_atmos/
	cp run_mpas_atmos.qsub ./${rundir}/mpas_atmos/
	cp restart_script.sh ./${rundir}/mpas_atmos/
	cp bash_atmos.sh ./${rundir}/mpas_atmos/
	cp setupMPAS ./${rundir}/mpas_atmos/

	cd ./${rundir}/mpas_atmos/

	ln -sf ${bpath}/${meshdir}/${grdprfx}*.graph.info.part.${ncores} .

	# modify run qsub
	nodes=$(( (ncores+24-1)/24 ))
	dstr6a="#PBS -l select=${nodes}:ncpus=24:mpiprocs=24:nodetype=haswell_reg"
	dstr6b="#PBS -N ${jobprfx}${yr}_${rsltn}-Atmos"
	dstr6c="CS=${rundir}"
	dstr6d="SIMDIR=${bpath}"
	dstr6e="nproc=${ncores}"
	sed -i "2s|.*|${dstr6a}|" run_mpas_atmos.qsub
	sed -i "8s|.*|${dstr6b}|" run_mpas_atmos.qsub
	sed -i "21s|.*|${dstr6c}|" run_mpas_atmos.qsub
	sed -i "22s|.*|${dstr6d}|" run_mpas_atmos.qsub
	sed -i "25s|.*|${dstr6e}|" run_mpas_atmos.qsub

	# modify namelist
	tmp=$( ls ${bpath}/${meshdir}/${grdprfx}*.grid.nc )  # get fullname of grid file e.g ~/x6.999426.grid.nc
	fname=$(basename "${tmp}" )  # extract filename only
	parts=( ${fname//./ } )     # split the name by "."
	drsltn=$(( lowRsltn * 5 ))  # calculate timestep in seconds (5sec per km is recommended)
	dwin=$(( lowRsltn * 1000 )) # calculate len_display in meters
	dstr6c="    config_dt = ${drsltn}.0"
	dstr6d="    config_len_disp = ${dwin}.0"
	dstr6e="    config_block_decomp_file_prefix = '${parts[0]}.${parts[1]}.graph.info.part.'"
	sed -i "3s|.*|${dstr6c}|" namelist.atmosphere_org
	sed -i "16s|.*|${dstr6d}|" namelist.atmosphere_org
	sed -i "44s|.*|${dstr6e}|" namelist.atmosphere_org

	# modify streams files
	astr2="                  filename_template='${parts[0]}.${parts[1]}.init.nc'"
	astr3="        filename_template='${parts[0]}.${parts[1]}.sfc_update.nc'"
	sed -i "4s|.*|${astr2}|" streams.atmosphere
	sed -i "42s|.*|${astr3}|" streams.atmosphere

	# modify bash script
	dstr7="CLIM_STARTYEAR='${simstartdate:0:4}'"
	dstr8="CLIM_ENDYEAR='${simenddate:0:4}'"
	dstr9="CLIM_STARTMON='${simstartdate:5:2}'"
	dstr10="CLIM_ENDMON='${simenddate:5:2}'"
	dstr11="CLIM_STARTDAY='${simstartdate:8:2}'"
	dstr12="CLIM_ENDDAY='${simenddate:8:2}'"
	dstr13="CLIM_STARTHOUR='${simstartdate:11:2}'"
	dstr14="CLIM_ENDHOUR='${simenddate:11:2}'"
	dstr15="rsltn='${rsltn}'"

	sed -i "44s|.*|${dstr7}|" bash_atmos.sh
	sed -i "45s|.*|${dstr8}|" bash_atmos.sh
	sed -i "46s|.*|${dstr9}|" bash_atmos.sh
	sed -i "47s|.*|${dstr10}|" bash_atmos.sh
	sed -i "48s|.*|${dstr11}|" bash_atmos.sh
	sed -i "49s|.*|${dstr12}|" bash_atmos.sh
	sed -i "50s|.*|${dstr13}|" bash_atmos.sh
	sed -i "51s|.*|${dstr14}|" bash_atmos.sh
	sed -i "52s|.*|${dstr15}|" bash_atmos.sh

	# run bash script
	./bash_atmos.sh

	cd "${bpath}/"
fi

echo "MPAS Automation finished"

} 2>&1 | tee -a ${LOGFILE}
