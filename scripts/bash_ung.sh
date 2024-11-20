#!/bin/bash

datapath='/home/amakinde/lustre/sims/mpas/60km_auto_mpas/data/cfsr'
prs_startdate="1980-06-30_00:00:00"
prs_enddate="1980-07-01_06:00:00"
sfc_startdate="1980-07-01_00:00:00"
sfc_enddate="1980-10-05_00:00:00"
multiyearsungrib=0

prs_styr=${prs_startdate:0:4}
prs_ndyr=${prs_enddate:0:4}
sfc_styr=${sfc_startdate:0:4}
sfc_ndyr=${sfc_enddate:0:4}
prs_stdt=${prs_startdate:5:14}
prs_nddt=${prs_enddate:5:14}
sfc_stdt=${sfc_startdate:5:14}
sfc_nddt=${sfc_enddate:5:14}

styr=$(( prs_styr + 0 ))
ndyr=$(( sfc_ndyr + 0 ))

if [ ${sfc_styr} -le ${styr} ]; then styr=${sfc_styr}; fi
if [ ${prs_ndyr} -ge ${ndyr} ]; then ndyr=${prs_ndyr}; fi

dpath="${datapath}/${styr}-${ndyr}"
multiyearsungrib=$(( multiyearsungrib + 0 ))

for d in $( seq $styr $ndyr )
do

	# if its not multiple years ungrib
	# then keep changing the path every iteration or every year
	if [ ${multiyearsungrib} -le 0 ]
	then
		dpath="${datapath}/${d}"
	fi

	if [ ${d} -ge ${prs_styr} ] && [ ${d} -le ${prs_ndyr} ]
	then
		yst=${d}
		ynd=${prs_ndyr}
		sdt=${prs_stdt}
		ndt=${prs_nddt}

		# if not the start years, create 2 days underlap
		if [ ${d} -gt ${prs_styr} ]
		then 
			yst=$(( d -1 ))
			sdt="12-30_00:00:00"
		fi

		# if not he end year, create 2 days overlap
		if [ ${d} -lt ${prs_ndyr} ]
		then 
			ynd=$(( d +1 ))
			ndt="01-02_00:00:00"
		fi
		echo ""
		echo "preparing to interpolate intermediate files for ${d}..."
		dsstr=" start_date = '${yst}-${sdt}',"
		destr=" end_date   = '${ynd}-${ndt}',"
		sed -i "4s|.*|${dsstr}|" namelist.wps_pres
		sed -i "5s|.*|${destr}|" namelist.wps_pres

		echo "linking pressure files..."
		rm GRIBFILE.* PRES*

		lsfiles=""
		for fl in $( seq $yst $ynd ); do lsfiles="$lsfiles ${dpath}/raw/plv_*${fl}*.grb2"; done
		ls ${lsfiles} 
		./link_grib.csh ${lsfiles}

		echo "start running ungrib for pressure intermediate files.."
		cp namelist.wps_pres namelist.wps
		ln -sf Vtable.CFSR_mpas_pres_sfc Vtable
		./ungrib.exe

		mv ungrib.log ungrib_${d}_PRES.log
		echo "moving pressure intermediate files to data directory.."
		cp PRES* ${dpath}/
	fi
# skip the rest
#	continue

	if [ ${d} -ge ${sfc_styr} ] && [ ${d} -le ${sfc_ndyr} ]
	then
		yst=${d}
		ynd=${sfc_ndyr}
		sdt=${sfc_stdt}
		ndt=${sfc_nddt}

		# if not the start years, create 2 days underlap
		if [ ${d} -gt ${sfc_styr} ]
		then 
			yst=$(( d -1 ))
			sdt="12-30_00:00:00"
		fi

		# if not he end year, create 2 days overlap
		if [ ${d} -lt ${sfc_ndyr} ]
		then 
			ynd=$(( d +1 ))
			ndt="01-02_00:00:00"
		fi

		echo ""
		echo "preparing to interpolate SST intermediate files for ${d}..."

		dsstr=" start_date = '${yst}-${sdt}',"
		destr=" end_date   = '${ynd}-${ndt}'"
		sed -i "4s|.*|${dsstr}|" namelist.wps_sst
		sed -i "5s|.*|${destr}|" namelist.wps_sst

		echo "linking SST files..."
		rm GRIBFILE.* SST*
		lsfiles=""
		for fl in $( seq $yst $ynd ); do lsfiles="$lsfiles ${dpath}/raw/${fl}*.grb2"; done
		./link_grib.csh ${lsfiles}

		echo "start running ungrib for SSt intermediate files.."
		cp namelist.wps_sst namelist.wps
		ln -sf Vtable.CFSR_mpas_pres_sfc Vtable
		./ungrib.exe

		mv ungrib.log ungrib_${d}_SST.log
		echo "moving SST intermediate files to data directory.."
		cp SST* ${dpath}/
	fi
done

touch ungrib.finished
echo "All done"
