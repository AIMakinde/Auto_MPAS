prfx1="$1"
prfx2="$2"
gridfname="$3"

shopt -s expand_aliases
source ~/.bashrc  # or source a file that contains your alias definitions

source setupMPAS
mv latlon.nc old_latlon.nc
convert_mpas ${gridfname} diag.2022-04-*

./cdo_mpas_postp_variables.sh $prfx1 $prfx2
./cdo_mpas_postp_geop.sh $prfx1 $prfx2
./cdo_mpas_postp_precipitation.sh $prfx1 $prfx2
./cdo_mpas_postp_EQPT.sh $prfx1 $prfx2
./prep_data_mpas.sh $prfx1 $prfx2
