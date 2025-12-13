#!/bin/bash

#=====================================================
# Modify the following path based on the WRF setup 
# on your platform
# module load chpc/netcdf/4.1.3/gcc-4.8.3  # for grid_rot
#=====================================================

cs_dir='utils'
working_dir="$( pwd )"
source_dir="/apps/chpc/earth/WRF-3.8-pnc-impi_hwl"
wrf_wps_dir="$source_dir/WPS"
wrf_run_dir="$source_dir/WRFV3/run"
geog_data="/mnt/lustre/users/amakinde/sims/mpas/mpas_static"
gdata="/mnt/lustre/users/amakinde/sims/mpas/mpas_static/topo_gmted2010_30s"
grid_rot="/mnt/lustre/users/amakinde/sims/mpas/grid_rotate"
conv_mpas="/mnt/lustre/users/amakinde/sims/mpas/convert_mpas"
ncl_dir="/mnt/lustre/users/amakinde/sims/mpas/ncl"
#====================================================
# Do not modify the following section
#====================================================
# Creat the case directory and change directory to it
echo "Creating the case study directory"
cd $working_dir
mkdir $cs_dir
cd $cs_dir
#mkdir inputData
#mkdir -p inputData/geog_static
#mkdir -p inputData/meteo
#cd inputData/geog_static
#ln -sf $source_dir/GEOG/* .

cd $working_dir/$cs_dir 

echo "Creating the preprocessing directory, ${cs_dir} and populating it with essential files"
mkdir wpsprd
cd wpsprd
cp $wrf_wps_dir/namelist.* .
cp $wrf_wps_dir/link_grib.csh .
#cp $working_dir/DMR_namelists/namelist.wps.DMR .

ln -sf $wrf_wps_dir/*.exe .
ln -sf $wrf_wps_dir/geogrid/*.exe .
ln -sf $wrf_wps_dir/geogrid/GEOGRID.TBL .
ln -sf $wrf_wps_dir/geogrid/ .
ln -sf $wrf_wps_dir/ungrib/ .
ln -sf $wrf_wps_dir/metgrid/ .
ln -sf $wrf_wps_dir/util .
echo "Following files and links have been created in ${cs_dir}/wpsprd"
ls -lsh

cd $working_dir/$cs_dir
echo "Creating convert_mpas"
mkdir convert_mpas
cd convert_mpas
ln -sf ${conv_mpas}/convert_mpas .
cp ${conv_mpas}/include* .
cp ${conv_mpas}/target* .
cd ..


mkdir ncl
cd ncl 
ln -sf ${ncl_dir}/* . 
cd ..

cd $working_dir/$cs_dir
echo "Grid rotate"
mkdir grid_rotate
cd grid_rotate
ln -sf ${grid_rot}/grid_rotate .
cp ${grid_rot}/*.ncl .
cp ${grid_rot}/namelist.input .


