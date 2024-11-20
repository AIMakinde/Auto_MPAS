
filenamepattern="hg_mpas6015_aug_*.nc"

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
    cdo setattribute,gz@long_name='Geopotential Height' -setattribute,gz@units=m -expr,'gz=6356766*hg/(6356766+hg)' $gfile gz_$gfile
done


# cdo setattribute,gz@long_name='Geopotential Height' -setattribute,gz@units=m -expr,'gz=6356766*hg/(6356766+hg)' hg_mpas6015_aug_1986.nc gz_mpas6015_aug_1986.nc
# cdo setattribute,gz@long_name='Geopotential Height' -setattribute,gz@units=m -expr,'gz=6356766*hg/(6356766+hg)' hg_mpas6015_aug_1989.nc gz_mpas6015_aug_1989.nc
# cdo setattribute,gz@long_name='Geopotential Height' -setattribute,gz@units=m -expr,'gz=6356766*hg/(6356766+hg)' hg_mpas6015_aug_1990.nc gz_mpas6015_aug_1990.nc
# cdo setattribute,gz@long_name='Geopotential Height' -setattribute,gz@units=m -expr,'gz=6356766*hg/(6356766+hg)' hg_mpas6015_aug_1994.nc gz_mpas6015_aug_1994.nc
# cdo setattribute,gz@long_name='Geopotential Height' -setattribute,gz@units=m -expr,'gz=6356766*hg/(6356766+hg)' hg_mpas6015_aug_1999.nc gz_mpas6015_aug_1999.nc
# cdo setattribute,gz@long_name='Geopotential Height' -setattribute,gz@units=m -expr,'gz=6356766*hg/(6356766+hg)' hg_mpas6015_aug_2000.nc gz_mpas6015_aug_2000.nc
