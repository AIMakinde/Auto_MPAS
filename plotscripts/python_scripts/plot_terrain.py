###############################################################################################
#
# This script was written with aggregated information from the websites below
#   1     Plot MPAS data using Delauney Triangulation :
#         https://gallery.pangeo.io/repos/NCAR/notebook-gallery/notebooks/Binderbot-Bug28/mpas/plot_terrain.html
#   2     Plot of Surface Pressure on MPAS grid:
#         https://gallery.pangeo.io/repos/NCAR/notebook-gallery/notebooks/Run-Anywhere/mpas/plot_of_surface_pressure_on_mpas_grid.html
#   3     MPL_terrain.rgb file from
#         https://www.ncl.ucar.edu/Document/Graphics/ColorTables/MPL_terrain.shtml
#
####################################################################################################

import xarray as xr
import numpy as np
import cartopy.crs as ccrs
import cartopy.feature as cfeature
import matplotlib.tri as tri
import matplotlib.pyplot as plt
from matplotlib.colors import ListedColormap
from cartopy.mpl.gridliner import LONGITUDE_FORMATTER, LATITUDE_FORMATTER


file = "x1.163842.static.nc"

ds = xr.open_dataset(file)

# Remove singleton dimensions, such as Time.
ds = ds.squeeze()
ds

# convert from radians to degree
lonData = np.degrees(ds.lonCell)
latData = np.degrees(ds.latCell)

# Make longitude cyclics
#ds["lonCell"] = dataLonCells
#ds["latCell"] = np.degrees(ds.latCell)

#lonData = ((lonData + 180) % 360) - 180

# compute triangulations
triang = tri.Triangulation(lonData, latData)

# load colormap values form ncl color map
cmap_file = "./MPL_terrain.rgb"
cm_custom_values = np.loadtxt(cmap_file)
(ncolors, nchannels) = cm_custom_values.shape
(ncolors, nchannels)
cm_custom_rgba = np.hstack( (cm_custom_values, np.ones( (ncolors,1) )) )
cm_custom_rgba.shape
cmap_custom = ListedColormap(cm_custom_rgba)


# Plot terrain

# Choose resolution of map features.
# Note that these features are downloaded when plotting for the first time, and for the ent$#  so requesting high resolution can take several minutes.
scale = '110m' # '50m' # '10m'


fig = plt.figure(figsize=(10,10))
proj1 = ccrs.Orthographic()
proj = ccrs.PlateCarree()
ax = fig.add_subplot(1,1,1, projection = proj)
ax.set_global()

# Set lat/lon bounding box and feature resolutions.
# ax.set_extent([-180, 180, -90, 90], crs=proj)

ax.add_feature(cfeature.LAND.with_scale(scale))
ax.add_feature(cfeature.OCEAN.with_scale(scale))
ax.add_feature(cfeature.STATES.with_scale(scale))
ax.add_feature(cfeature.LAKES.with_scale(scale), alpha=0.5)
ax.add_feature(cfeature.COASTLINE.with_scale(scale))

# Specify data range for colormap
(colormin, colormax) = (np.min(ds.ter), np.max(ds.ter))

mm = ax.tripcolor(triang, ds.ter, edgecolors='none', transform=proj, cmap=cmap_custom, vmin=colormin, vmax=colormax)

gl = ax.gridlines(draw_labels=True)
gl.xformatter = LONGITUDE_FORMATTER
gl.yformatter = LATITUDE_FORMATTER
gl.xlabels_top = gl.ylabels_right = False
gl.xlines = gl.ylines = False

plt.colorbar(mm, orientation='horizontal', pad=0.03)
plt.title(f"MPAS terrain height ({len(ds.lonCell)} cells)", fontweight="bold", fontsize=14)



# show figure
#plt.show()

# save figure to file
fig.savefig('./plot_terrain.png')
