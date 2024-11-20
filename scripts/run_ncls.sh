

module load chpc/earth/ncview/2.1.7-gcc

export GNAME=x1.163842.grid.nc
export FNAME=x1.163842.init.nc
export T=0


ncl mpas-a_cells.ncl
ncl mpas-a_mesh.ncl
ncl mpas-a_xsec.ncl
ncl plot_ivgtyp.ncl
ncl plot_qv.ncl
ncl plot_terrain.ncl
ncl plot_tsk.ncl

export FNAME=x1.163842.init.nc
ncl mpas-a_contours.ncl

export FNAME=x1.163842.sfc_update.nc
ncl plot_delta_sst.ncl
