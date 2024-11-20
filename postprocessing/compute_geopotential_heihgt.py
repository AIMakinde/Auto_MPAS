#!/usr/bin/env python

#***********************************************************************
 #
 #  routine compute_geopotential_height
 #
 #> \brief   Convert geometric height to geopotential height
 #>          Adopted from compute_geopotential_height.f90. 
 #> \author  Soyoung Ha
 #> \date    17 Feb 2017
 #
 #> \adapted  AI Makinde
 #> \date        26-08-2021
 #
 #> \details
 #>  Given latitude (in degree), convert geometric height (in meter)
 #>  into geopotential height (in meter).
 #>  
 #>  Input:   
 #>  ncol -- nCells
 #>  nlev -- nIsobaricLevels
 #>  lat  -- latitude [radian]   
 #>  H    -- geometric height [m]
 #>  
 #>  Output:   
 #>  GPH  -- geopotential height [m]
 #>  
 #----------------------------------------------------------------------- 
 
from netCDF4 import Dataset
from numpy.lib import math
from scipy.interpolate import interp1d
import sys
import numpy as np
 
 
def compute_geopoH (filename, outfilename):
    #
    # Set the fields name
    #
    field_names = 'zgrid'
    outfilename = "test.nc"

    #
    # Set the fill value to be used for points that are below ground
    # or above the model top
    #
    fill_val = -1.0e34


    print(' Opening '+filename + '.....')
    #
    # Read 3-d pressure, zonal wind, and meridional wind fields
    # on model zeta levels
    #
    f = Dataset(filename)

    nCells = f.dimensions['nCells'].size
    nVertLevels = f.dimensions['nVertLevels'].size
    lat = f.variables['lat'][:]
    nlat = f.variables['lat'].size
    hgt=f.variables['height'][:]
    
    #  Local variables
    ghgt=np.empty(hgt.shape)
    sin2 = np.empty(nlat)
    termg = np.empty(nlat)
    termr = np.empty(nlat)
    k, iCell = 0

    #  Parameters below from WGS-84 model software inside GPS receivers.
    semi_major_axis = 6378.1370e3                  # (m)
    semi_minor_axis = 6356.7523142e3            # (m)
    grav_polar = 9.8321849378                         # (m/s2)
    grav_equator = 9.7803253359                     # (m/s2)
    earth_omega = 7.292115e-5                        #(rad/s)  
    grav = 9.80665                                             # (m/s2) WMO std g at 45 deg lat
    grav_constant = 3.986004418e14                #(m3/s2)
    eccentricity = 0.081819                                # unitless

    #  Derived geophysical constants
    flattening = (semi_major_axis-semi_minor_axis) / semi_major_axis
    somigliana = (semi_minor_axis/semi_major_axis)*(grav_polar/grav_equator)-1.0
    grav_ratio = (earth_omega*earth_omega * semi_major_axis*semi_major_axis * semi_minor_axis)/grav_constant
    sin2  = np.sin(lat)**2
    termg = grav_equator * ( (1.0+somigliana*sin2) / np.sqrt(1.0 - eccentricity**2 * sin2) )
    termr = semi_major_axis / (1.0 + flattening + grav_ratio - 2.0*flattening*sin2)


    print(' creating output file....')
    #
    # Create netCDF output file
    #
    f = Dataset(outfilename, 'w', clobber=False)

    f.createDimension('Time', size=None)
    f.createDimension('nCells', size=nCells)

    for field in isobaric_fieldnames:
        f.createVariable(field, 'f', dimensions=('Time','nCells'), fill_value=fill_val)

    for cell in np.arange(nCells):
        for lev in np.arange(nVertLevels):
            sin2 = np.sin(lat(cell))**2
            termg = grav_equator * ( (1.0 + somigliana * sin2) / np.sqrt(1.0 - eccentricity**2 * sin2) )
            termr = semi_major_axis / (1.0 + flattening + grav_ratio - 2.0*flattening*sin2)
            ghgt.append
            GPH(k,iCell) = (termg(iCell)/grav)*((termr(iCell)*hgt(k,iCell))/(termr(iCell)+hgt(k,iCell)))
