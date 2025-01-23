# Updates MPAS intermediate initial condition, PRESS,
# file with SST and land sea mask

for pfile in `ls PRES:*`
do
    fdate=${pfile//PRES:/}
    sfile="SST:${fdate}"
    cat $sfile >> $pfile
    echo "$pfile is updated"
done
