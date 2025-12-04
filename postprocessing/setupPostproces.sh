#!/bin/bash

main_sim_dir=("tests")
simdir_prfx=""
simdir_sufx=""  #"_sims"
exp_sim_dir=("test01") # "test02" "test03" "test04" "test05" "test06" "test07" "test08" "test09" "test10")
convt-mpas_prfx="6003km"
rslt_dir_name="2022"
gridfname="x20.835586.grid.nc"

# Get into the simulation directory
basedir=/mnt/lustre/users/amakinde/sims/mpas/test_colsims
ppscriptdir="${basedir}/postprocessing"
meshdir="${basedir}/meshes/${convt-mpas_prfx}/regrid_sa"

cd ${basedir}

shopt -s expand_aliases
source ~/.bashrc  # or source a file that contains your alias definitions

for simdir in "${main_sim_dir[@]}"
do
    cd ${basedir}
    for ensdir in "${exp_sim_dir[@]}"
    do
        prfx1=${simdir}
        prfx2=${ensdir//bl/}

	    cp ${ppscriptdir}/cdo_mpas_postp_variables.sh "${simdir_prfx}${simdir}${simdir_sufx}/${ensdir}/mpas_atmos/${rslt_dir_name}/"
        cp ${ppscriptdir}/cdo_mpas_postp_precipitation.sh "${simdir_prfx}${simdir}${simdir_sufx}/${ensdir}/mpas_atmos/${rslt_dir_name}/"
        cp ${ppscriptdir}/cdo_mpas_postp_geop.sh "${simdir_prfx}${simdir}${simdir_sufx}/${ensdir}/mpas_atmos/${rslt_dir_name}/"
        cp ${ppscriptdir}/cdo_mpas_postp_EQPT.sh "${simdir_prfx}${simdir}${simdir_sufx}/${ensdir}/mpas_atmos/${rslt_dir_name}/"
        cp ${ppscriptdir}/bash_postproces.sh "${simdir_prfx}${simdir}${simdir_sufx}/${ensdir}/mpas_atmos/${rslt_dir_name}/"
        cp ${ppscriptdir}/prep_data_mpas.sh "${simdir_prfx}${simdir}${simdir_sufx}/${ensdir}/mpas_atmos/${rslt_dir_name}/"
        cp ${ppscriptdir}/*.txt "${simdir_prfx}${simdir}${simdir_sufx}/${ensdir}/mpas_atmos/${rslt_dir_name}/"
        cp ${ppscriptdir}/include_fields_${convt-mpas_prfx} "${simdir_prfx}${simdir}${simdir_sufx}/${ensdir}/mpas_atmos/${rslt_dir_name}/include_fields"
        cp ${ppscriptdir}/target_domain_${convt-mpas_prfx} "${simdir_prfx}${simdir}${simdir_sufx}/${ensdir}/mpas_atmos/${rslt_dir_name}/target_domain"
        cp setupMPAS "${simdir_prfx}${simdir}${simdir_sufx}/${ensdir}/mpas_atmos/${rslt_dir_name}/"
        ln -sf ${meshdir}/${gridfname} "${simdir_prfx}${simdir}${simdir_sufx}/${ensdir}/mpas_atmos/${rslt_dir_name}/"
        
        cd $basedir
    done
    
done