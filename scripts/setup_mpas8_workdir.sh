#!/bin/bash

workdir='era5_60km_uniform'
mpas_root_dir=/mnt/lustre/users/amakinde/sims/mpas/MPAS-Model-8.2.2-modifiedregistry   #/mnt/lustre/groups/ERTH0904/Models/MPAS/MPAS-Model-8.0.2-Single
geog_data=/mnt/lustre/users/amakinde/sims/mpas/mpas_static            #/mnt/lustre/groups/ERTH0904/MPAS-Statics/MPAS_GEOG
gdata=/mnt/lustre/users/amakinde/sims/mpas/mpas_static/topo_gmted2010_30s    #/mnt/lustre/groups/ERTH0904/MPAS-Statics/MPAS_GEOG/topo_gmted2010_30s

mkdir -p $workdir
cd $workdir

#link static terrestrial data
ln -sf ${geog_data} GEOG
ln -sf ${gdata} topo_gmted2010_30s

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

cp ${mpas_root_dir}/stream_list.atmosphere.diagnostics .
cp ${mpas_root_dir}/stream_list.atmosphere.diagnostics .
cp ${mpas_root_dir}/stream_list.atmosphere.output .
cp ${mpas_root_dir}/stream_list.atmosphere.surface .
cp ${mpas_root_dir}/streams.atmosphere .
cp ${mpas_root_dir}/streams.init_atmosphere .
cp ${mpas_root_dir}/namelist.atmosphere  .

ln -sf ${mpas_root_dir}/testing_and_setup .



