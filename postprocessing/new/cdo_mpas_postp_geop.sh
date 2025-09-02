

prfx1="$1"
prfx2="$2"
filenamepattern="hg_hrs_mpas60_${prfx1}_${prfx2}-p5_era5_*.nc"

#================================
#                          Ro * z
# geopotential Height h = -----------
#                           (Ro + z)
#
#
#where Ro = 6356.766 km
#      Ro = 6356766 m
#

for gfile in `ls $filenamepattern`
do
    ofile="${gfile//hg/zg}"
    cdo setattribute,zg@long_name='Geopotential Height' -setattribute,zg@units=m -expr,'zg=6356766*hg/(6356766+hg)' $gfile $ofile
done


# cdo setattribute,gz@long_name='Geopotential Height' -setattribute,gz@units=m -expr,'gz=6356766*hg/(6356766+hg)' hg_mpas6015_aug_1986.nc gz_mpas6015_aug_1986.nc
# cdo setattribute,gz@long_name='Geopotential Height' -setattribute,gz@units=m -expr,'gz=6356766*hg/(6356766+hg)' hg_mpas6015_aug_1989.nc gz_mpas6015_aug_1989.nc
# cdo setattribute,gz@long_name='Geopotential Height' -setattribute,gz@units=m -expr,'gz=6356766*hg/(6356766+hg)' hg_mpas6015_aug_1990.nc gz_mpas6015_aug_1990.nc
# cdo setattribute,gz@long_name='Geopotential Height' -setattribute,gz@units=m -expr,'gz=6356766*hg/(6356766+hg)' hg_mpas6015_aug_1994.nc gz_mpas6015_aug_1994.nc
# cdo setattribute,gz@long_name='Geopotential Height' -setattribute,gz@units=m -expr,'gz=6356766*hg/(6356766+hg)' hg_mpas6015_aug_1999.nc gz_mpas6015_aug_1999.nc
# cdo setattribute,gz@long_name='Geopotential Height' -setattribute,gz@units=m -expr,'gz=6356766*hg/(6356766+hg)' hg_mpas6015_aug_2000.nc gz_mpas6015_aug_2000.nc
