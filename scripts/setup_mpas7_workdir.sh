#!/bin/bash

workdir='6003km_variable'
mpas_root_dir=/mnt/lustre/users/amakinde/softw/MPAS-Model
geog_data=/mnt/lustre/users/rtakong/case_studies/GEOG
gdata=/mnt/lustre/users/rtakong/case_studies/GEOGtopo_gmted2010_30s

mkdir -p $workdir
cd $workdir

#link static terrestrial data
ln -sf ${geog_data} .
ln -sf ${gdata} .

# files needed for model
mkdir -p mpas_init
cd mpas_init


ln -s ${mpas_root_dir}/init_atmosphere_model .
cp ${mpas_root_dir}/namelist.init_atmosphere .
cp ${mpas_root_dir}/streams.init_atmosphere .
cd ..


mkdir -p mpas_atmos
cd mpas_atmos

ln -sf ${mpas_root_dir}/atmosphere_model .
ln -sf ${mpas_root_dir}/build_tables .
ln -sf ${mpas_root_dir}/*.DBL .
ln -sf ${mpas_root_dir}/default_inputs .
ln -sf ${mpas_root_dir}/*.TBL .
ln -sf ${mpas_root_dir}/src/core_atmosphere/physics/physics_wrf/files/RRTMG_LW_DATA .
ln -sf ${mpas_root_dir}/src/core_atmosphere/physics/physics_wrf/files/RRTMG_SW_DATA .
ln -sf ${mpas_root_dir}/src/core_atmosphere/physics/physics_wrf/files/MP_THOMPSON_QIautQS_DATA.DBL .
ln -sf ${mpas_root_dir}/src/core_atmosphere/physics/physics_wrf/files/MP_THOMPSON_QRacrQG_DATA.DBL .
ln -sf ${mpas_root_dir}/src/core_atmosphere/physics/physics_wrf/files/MP_THOMPSON_QRacrQS_DATA.DBL .
ln -sf ${mpas_root_dir}/src/core_atmosphere/physics/physics_wrf/files/MP_THOMPSON_freezeH2O_DATA.DBL .
cp ${mpas_root_dir}/stream_list.atmosphere.diagnostics .
cp ${mpas_root_dir}/stream_list.atmosphere.diagnostics .
cp ${mpas_root_dir}/stream_list.atmosphere.output .
cp ${mpas_root_dir}/stream_list.atmosphere.surface .
cp ${mpas_root_dir}/streams.atmosphere .
cp ${mpas_root_dir}/streams.init_atmosphere .
cp ${mpas_root_dir}/namelist.atmosphere  .

ln -sf ${mpas_root_dir}/testing_and_setup .


