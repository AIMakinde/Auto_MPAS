#!/usr/bin/env python
# Orignal Script from: MGUDA (MPAS co-Developer)
# Addapted By: AI Makinde
# Adapted On: 08-11-2020
# Last Modified : 21-03-2024
# Contact: mckynde@gmail.com

"""
 Vertically interpolate MPAS-Atmosphere fields to a specified set
 of isobaric levels. The interpolation is linear in log-pressure.

 Variables to be set in this script include:
    - levs_hPa : a list of isobaric levels, in hPa
    - field_names : a list of names of fields to be vertically interpolated
                    these fields must be dimensioned by ('Time', 'nCells', 'nVertLevels')
    - fill_val : a value to use in interpolated fields to indicate values below
                 the lowest model layer midpoint or above the highest model layer midpoint
"""


from netCDF4 import Dataset
from scipy.interpolate import interp1d
import sys
import numpy as np
import os


if len(sys.argv) < 2 or len(sys.argv) > 3:
    print('')
    print('Usage: isobaric_interp.py <input filename> [output filename]')
    print('')
    print('       Where <input filename> is the name of an MPAS-Atmosphere netCDF file')
    print('       containing a 3-d pressure field as well as all 3-d fields to be vertically')
    print('       interpolated to isobaric levels, and [output filename] optionally names')
    print('       the output file to be written with vertically interpolated fields.')
    print('')
    print('       If an output filename is not given, interpolated fields will be written')
    print('       to a file named isobaric.nc.')
    print('')
    exit()





def interp_tofixed_pressure(ncol, nlev_in, nlev_out, pres_in, field_in, pres_out, lev_vals):
    """
    Interpolates a given field to specified fixed pressure levels.
    
    Parameters:
    ncol (int): Number of columns (nCells)
    nlev_in (int): Number of input levels (nVertLevels)
    nlev_out (int): Number of output levels (fixed pressure levels)
    pres_in (2D array): Input pressure array of shape (ncol, nlev_in)
    field_in (2D array): Input field array of shape (ncol, nlev_in)
    pres_out (2D array): Output pressure array of shape (ncol, nlev_out)
    field_out (2D array): Output field array of shape (ncol, nlev_out)
    """
    kupper = np.ones(ncol, dtype=int)
    field_out = np.full((ncol, nlev_out), np.nan) # Initialize field_out to NaN

    for k in range(nlev_out):
        print(f"          [+] {lev_vals[k]}")
        kkstart = nlev_in
        for icol in range(ncol):
            kkstart = min(kkstart, kupper[icol])
        
        kount = 0
        
        for kk in range(kkstart, nlev_in - 1):
            for icol in range(ncol):
                if pres_out[icol, k] > pres_in[icol, kk] and pres_out[icol, k] <= pres_in[icol, kk + 1]:
                    kupper[icol] = kk
                    kount += 1
            
            if kount == ncol:
                for icol in range(ncol):
                    dpu = pres_out[icol, k] - pres_in[icol, kupper[icol]]
                    dpl = pres_in[icol, kupper[icol] + 1] - pres_out[icol, k]
                    field_out[icol, k] = (field_in[icol, kupper[icol]] * dpl + field_in[icol, kupper[icol] + 1] * dpu) / (dpl + dpu)
                break
        
        for icol in range(ncol):
            if pres_out[icol, k] < pres_in[icol, 0]:
                field_out[icol, k] = field_in[icol, 0] * pres_out[icol, k] / pres_in[icol, 0]
            elif pres_out[icol, k] > pres_in[icol, nlev_in - 1]:
                field_out[icol, k] = field_in[icol, nlev_in - 1]
            else:
                dpu = pres_out[icol, k] - pres_in[icol, kupper[icol]]
                dpl = pres_in[icol, kupper[icol] + 1] - pres_out[icol, k]
                field_out[icol, k] = (field_in[icol, kupper[icol]] * dpl + field_in[icol, kupper[icol] + 1] * dpu) / (dpl + dpu)

    return field_out




print(' Starting Isobaric interpolation')
filename = sys.argv[1]
if len(sys.argv) == 3:
    outfile = sys.argv[2]
else:
    outfile = os.path.basename(filename)
    outfile = "iso_"+outfile


#
# Set list of isobaric levels (in hPa)
#
#levs_hPa = [ 1000.0, 975.0, 950.0, 925.0, 900.0,
#              850.0, 800.0, 750.0, 700.0, 650.0,
#              600.0, 550.0, 500.0, 450.0, 400.0,
#              350.0, 300.0, 250.0, 200.0, 150.0,
#              100.0,  70.0,  50.0,  30.0,  20.0,
#               10.0 ]

levs_hPa = [ 1000.0, 925.0, 850.0, 700.0, 600.0,
            500.0, 400.0, 300.0, 250.0, 200.0, 150.0,
            100.0,  70.0,  50.0,  30.0,  20.0, 10.0,
            5.0, 1.0 ]


#
# Set list of fields, each of which must be dimensioned
# by ('Time', 'nCells', 'nVertLevels')
#
field_names = [ 'uReconstructZonal'] #, 'uReconstructMeridional','ertel_pv']


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
nOutLevels = len(levs_hPa)
pressure = f.variables['pressure'][:]

xtime = f.variables['xtime'][:]

print(' reading specified variables...')
fields = []
for field in field_names:
    fields.append(f.variables[field][:])


print(' closing data ' + filename )
f.close()


print(' computing logarithm of isobaric levels  and 3-d pressure fields')
#
# Convert pressure from Pa to hPa
#
pressure = pressure * 0.01


#
# Compute logarithm of isobaric level values and 3-d pressure field
#
pressure = np.log(pressure)
levs = np.log(levs_hPa)


print(' creating list of output field variables.....')
#
# Allocate list of output fields
#
isobaric_fields = []
isobaric_fieldnames = []
for field in field_names:
    for lev in levs_hPa:
        isobaric_fields.append(np.full((nCells), np.nan))  # Initialize field_out to NaN

        if lev >= 1000:
            isobaric_fieldnames.append(field+'_'+'surface')
        else:
            isobaric_fieldnames.append(field+'_'+repr(round(lev))+'hPa')


print(' creating output file....')
#
# Create netCDF output file
#
f = Dataset(outfile, 'w', clobber=True)#=False

f.createDimension('Time', size=None)
f.createDimension('nCells', size=nCells)

for field in isobaric_fieldnames:
    f.createVariable(field, 'f', dimensions=('Time','nCells'), fill_value=fill_val)



print('  Interpolation to isobaric levels')
#
# Loop over times
#
for t in range(len(xtime)):

    timestring = xtime[t,0:19].tobytes()
    print('   Interpolating fields at time '+timestring.decode('utf-8'))

    print('    starting vertical interpolations')
    #
    # Vertically interpolate
    #
    
    i = -1
    for field in fields:
        i = i + 1
        print('        interpolating '+field_names[i])
        ndlevels = np.tile(levs, (nCells, 1))
        field_out = interp_tofixed_pressure(nCells, nVertLevels, nOutLevels,pressure[t,:,:],field[t,:,:],ndlevels, levs_hPa)
        j = i * len(levs)
        for ilev in range(len(levs)):
            isobaric_fields[j] = field_out[:,ilev]
            j = j + 1


    print('     writing interpolated fields to file...')
    #
    # Save interpolated fields
    #
    for i in range(len(isobaric_fieldnames)):
        f.variables[isobaric_fieldnames[i]][t,:] = isobaric_fields[i][:]

print(' finalizing....')
f.close()


print(' Isobaric interpolation finished successfully')
