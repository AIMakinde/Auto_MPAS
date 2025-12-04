#!/bin/bash
#PBS -l select=1:ncpus=24:mpiprocs=24:mem=120gb:nodetype=haswell_reg
#PBS -P ERTH0904
#PBS -q smp
#PBS -l walltime=48:00:00
#PBS -m abe
#PBS -N MPAS6003_PostProc
#PBS -o static_stdout
#PBS -e static_stderr
#PBS -M mckynde@gmail.com
#PBS -V



simdirs=("coolac" "warmac")
simdir_prfx=""
simdir_sufx=""  #"_sims"
ensdirs=("ctrl" "ensbl01" "ensbl02" "ensbl03" "ensbl04" "ensbl05" "ensbl06" "ensbl07" "ensbl08" "ensbl09" "ensbl10")
includeprfx="6003km"
gridfname="x20.835586.grid.nc"

max_ppt=10
nppt=0

# Get into the simulation directory
basedir=/mnt/lustre/users/amakinde/sims/mpas/test_colsims
ppscriptdir=/mnt/lustre/users/amakinde/sims/mpas/test_colsims/postprocessing

cd ${basedir}

shopt -s expand_aliases
source ~/.bashrc  # or source a file that contains your alias definitions

for simdir in "${simdirs[@]}"
do
    cd ${basedir}
    for ensdir in "${ensdirs[@]}"
    do
        prfx1=${simdir}
        prfx2=${ensdir//bl/}

	    cp ${ppscriptdir}/cdo_mpas_postp_variables.sh "${simdir_prfx}${simdir}${simdir_sufx}/${ensdir}/mpas_atmos/2022/"
        cp ${ppscriptdir}/cdo_mpas_postp_precipitation.sh "${simdir_prfx}${simdir}${simdir_sufx}/${ensdir}/mpas_atmos/2022/"
        cp ${ppscriptdir}/cdo_mpas_postp_geop.sh "${simdir_prfx}${simdir}${simdir_sufx}/${ensdir}/mpas_atmos/2022/"
        cp ${ppscriptdir}/cdo_mpas_postp_EQPT.sh "${simdir_prfx}${simdir}${simdir_sufx}/${ensdir}/mpas_atmos/2022/"
        cp ${ppscriptdir}/bash_postproces.sh "${simdir_prfx}${simdir}${simdir_sufx}/${ensdir}/mpas_atmos/2022/"
        cp ${ppscriptdir}/prep_data_mpas.sh "${simdir_prfx}${simdir}${simdir_sufx}/${ensdir}/mpas_atmos/2022/"
        cp ${ppscriptdir}/*.txt "${simdir_prfx}${simdir}${simdir_sufx}/${ensdir}/mpas_atmos/2022/"
        cp ${ppscriptdir}/include_fields_${includeprfx} "${simdir_prfx}${simdir}${simdir_sufx}/${ensdir}/mpas_atmos/2022/include_fields"
        cp ${ppscriptdir}/target_domain_${includeprfx} "${simdir_prfx}${simdir}${simdir_sufx}/${ensdir}/mpas_atmos/2022/target_domain"
        cp setupMPAS "${simdir_prfx}${simdir}${simdir_sufx}/${ensdir}/mpas_atmos/2022/"
        ln -sf ${basedir}/meshes/${includeprfx}/regrid_sa/${gridfname} "${simdir_prfx}${simdir}${simdir_sufx}/${ensdir}/mpas_atmos/2022/"
        cd "${simdir_prfx}${simdir}${simdir_sufx}/${ensdir}/mpas_atmos/2022"

        ./bash_postproces.sh $prfx1 $prfx2 $gridfname > log.$prfx1_$prfx2 2>$1 &
        
        nppt=$(( nppt + 1 ))
        if [[ $nppt -ge $max_ppt ]]
        then
            echo "Maximum allowable concurrent postprocessing is reached"
            eco "waiting for ${nppt} jobs to finish."

            wait
            nppt=0
        fi
        
        cd $basedir
    done
    
done

echo "Waiting for all processes to finishe..."
wait


for simdir in "${simdirs[@]}"
do
    cd ${basedir}
    for ensdir in "${ensdirs[@]}"
    do
        prfx1=${simdir}
        prfx2=${ensdir//bl/}

        cd $basedir
        cd "${simdir_prfx}${simdir}${simdir_sufx}/"
        ln -sf ./${ensdir}/mpas_atmos/2022/mpas6003_${prfx1}_${prfx2}-p027_era5_3hrs_apr2022.nc .
        ln -sf ./${ensdir}/mpas_atmos/2022/prc_hrs_mpas6003_${prfx1}_${prfx2}-p027_era5_2022.nc .
        cd $basedir
    done
    
    cd ${basedir}
    cd "${simdir_prfx}${simdir}${simdir_sufx}/"
    cdo ensmean mpas6003_${prfx1}_*-p027_era5_3hrs_apr2022.nc mpas6003_${prfx1}_ensmean_p027_3hrs_apr2022.nc
    cdo merge prc_hrs_mpas6003_${prfx1}_*-p027_era5_2022.nc prc_mpas6003_${prfx1}_ensembles_p027_3hrs_apr2022.nc
done
