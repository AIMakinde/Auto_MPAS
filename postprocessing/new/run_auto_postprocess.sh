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




simdirs=("warmac") #"coolac" "warmac")
ensdirs=("ensbl01" "ensbl02" "ensbl03" "ensbl04" "ensbl05" "ensbl06" "ensbl07" "ensbl08" "ensbl09" "ensbl10")
includeprfx="60km"
gridfname="x1.163842.grid.nc"


# Get into the simulation directory
basedir=/mnt/lustre/users/amakinde/sims/mpas/agulhas_60km_exp
cd ${basedir}

shopt -s expand_aliases
source ~/.bashrc  # or source a file that contains your alias definitions

isfirst=1
for simdir in "${simdirs[@]}"
do
    cd ${basedir}
    for ensdir in "${ensdirs[@]}"
    do
	
        prfx1=${simdir}
        prfx2=${ensdir//bl/}
	logfile="log.${simdir}-${ensdir}"

	cp ./postprocscripts/cdo_mpas_postp_variables.sh ${simdir}_sim/${ensdir}/mpas_atmos/2022/
        cp ./postprocscripts/cdo_mpas_postp_precipitation.sh ${simdir}_sim/${ensdir}/mpas_atmos/2022/
        cp ./postprocscripts/cdo_mpas_postp_geop.sh ${simdir}_sim/${ensdir}/mpas_atmos/2022/
        cp ./postprocscripts/cdo_mpas_postp_EQPT.sh ${simdir}_sim/${ensdir}/mpas_atmos/2022/
        cp ./postprocscripts/bash_postproces.sh ${simdir}_sim/${ensdir}/mpas_atmos/2022/
        cp ./postprocscripts/prep_data_mpas.sh ${simdir}_sim/${ensdir}/mpas_atmos/2022/
        cp ./postprocscripts/*.txt ${simdir}_sim/${ensdir}/mpas_atmos/2022/
        cp include_fields_${includeprfx} ${simdir}_sim/${ensdir}/mpas_atmos/2022/include_fields
        cp target_domain_${includeprfx} ${simdir}_sim/${ensdir}/mpas_atmos/2022/target_domain
        cp setupMPAS ${simdir}_sim/${ensdir}/mpas_atmos/2022/
        ln -sf ${basedir}/meshes/${includeprfx}/${gridfname} ${simdir}_sim/${ensdir}/mpas_atmos/2022/
        cd ${simdir}_sim/${ensdir}/mpas_atmos/2022
        source setupMPAS

        # rm latlon.nc
        # convert_mpas ${gridfname} diag.2022-04-*
        ./bash_postproces.sh $prfx1 $prfx2 $gridfname > "$logfile" 2>&1 &

        cd $basedir
    done
    wait
    echo "All $simdir had finished" 
done


wait
echo "all background processess has finished"
echo "Beginning final processing..."

for simdir in "${simdirs[@]}"
do
    cd ${basedir}
    for ensdir in "${ensdirs[@]}"
    do
	cd ${basedir}
        prfx1=${simdir}
        prfx2=${ensdir//bl/}
	cd ${simdir}_sim/
	ln -sf ./${ensdir}/mpas_atmos/2022/mpas60_${prfx1}_${prfx2}-p5_era5_3hrs_apr2022.nc .
    done
    
    cd ${basedir}
    cd ${simdir}_sim/
    cdo ensmean mpas60_${prfx1}_*-p5_era5_3hrs_apr2022.nc mpas60_${prfx1}_ensmean_p5_3hrs_apr2022.nc
done
