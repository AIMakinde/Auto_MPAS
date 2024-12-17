#!/usr/bin/env python
# Orignal Script from: MGUDA (MPAS co-Developer)
# Addapted By: AI Makinde
# Adapted On: 15-11-2024
# Last Modified : 15-11-2024
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


import argparse
import numpy as np
from netCDF4 import Dataset
import os, shutil
from multiprocessing import Pool


def interp_tofixed_pressure(ncol, nlev_in, nlev_out, pres_in, field_in, pres_out):
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
    field_out = np.full((ncol, nlev_out), np.nan)  # Initialize field_out to NaN

    for k in range(nlev_out):
        kkstart = np.min(kupper)
        for kk in range(kkstart, nlev_in - 1):
            mask = (pres_out[:, k] > pres_in[:, kk]) & (pres_out[:, k] <= pres_in[:, kk + 1])
            kupper[mask] = kk
            if np.sum(mask) == ncol:
                break
        dpu = pres_out[:, k] - pres_in[np.arange(ncol), kupper]
        dpl = pres_in[np.arange(ncol), kupper + 1] - pres_out[:, k]
        field_out[:, k] = np.where(
            pres_out[:, k] < pres_in[:, 0],
            field_in[:, 0] * pres_out[:, k] / pres_in[:, 0],
            np.where(
                pres_out[:, k] > pres_in[:, nlev_in - 1],
                field_in[:, nlev_in - 1],
                (field_in[np.arange(ncol), kupper] * dpl + field_in[np.arange(ncol), kupper + 1] * dpu) / (dpl + dpu)
            )
        )
    return field_out


def calculate_pressure2(pressure, height, nCells, nVertLevelsP1, nTimes):
    """
    Calculate the pressure2 array for variables with nVertLevelsP1 dimensions.
    Returns pressure2 with shape (nCells, nVertLevelsP1).
    """
    pressure2 = np.full((nTimes, nCells, nVertLevelsP1), np.nan)  # Initialize pressure2 array with NaNs

    # Calculate pressure2 for the top level (index nVertLevelsP1 - 1)
    k = nVertLevelsP1 - 1
    z0 = height[:, k]
    z1 = 0.5 * (z0 + height[:,k-1])
    z2 = 0.5 * (height[:, k-1] + height[:, k-2])
    w1 = (z0 - z2) / (z1 - z2)
    w2 = 1. - w1
    pressure2[:,:, k] = np.exp(w1 * np.log(pressure[:,:, k-1]) + w2 * np.log(pressure[:,:, k-2]))

    # Calculate pressure2 for the intermediate levels (2 to nVertLevels)
    for k in range(1, nVertLevelsP1-1):
        z0 = height[:,k]
        z1 = height[:,k+1] - height[:,k-1]
        w1 = (z0 - height[:,k-1]) / z1
        w2 = (height[:,k+1] - z0) / z1
        pressure2[:,:, k] = np.exp(w1 * np.log(pressure[:,:, k]) + w2 * np.log(pressure[:,:, k-1]))

    # Calculate pressure2 for the bottom level (index 0)
    k = 0
    z0 = height[:,k]
    z1 = 0.5 * (z0 + height[:,k+1])
    z2 = 0.5 * (height[:, k+1] + height[:, k+2])
    w1 = (z0 - z2) / (z1 - z2)
    w2 = 1. - w1
    pressure2[:,:, k] = np.exp(w1 * np.log(pressure[:,:, k]) + w2 * np.log(pressure[:,:, k+1]))

    return pressure2

def generate_new_var_name(varname, lev:int):
    var_out_name = f"{varname}_{lev}hPa"
    if(lev >= 1000):
        var_out_name = f"{varname}_surface"

    return var_out_name

def interpolate_and_save(input_file, output_file, variables, levs_hPa, fill_val):
    print(f'Processing file: {input_file}')

    print(f'  Creating output file: {output_file}')
    shutil.copyfile(input_file, output_file) #Duplicate input to output

    print(f'  Checking input file for specified variables...')
    with Dataset(input_file) as src, Dataset(output_file, 'a') as dst:
        # Check for dimensions in the file
        nCells = src.dimensions['nCells'].size
        nVertLevels = src.dimensions['nVertLevels'].size
        xtime = src.variables['xtime'][:]
        nVertLevelsP1 = nVertLevels + 1  # Assume one additional level
        nLevels_in = nVertLevels
        
        # Check for 'pressure' variables
        if 'pressure' not in src.variables:
            raise KeyError("Variable 'pressure' is required but not found in the input file.")
        
        pressure = src.variables['pressure'][:]
        
        # Calculate pressure2 if any variable requires nVertLevelsP1
        requires_pressure2 = any(
            'nVertLevelsP1' in src.variables[var].dimensions for var in variables if var in src.variables
        )
        if requires_pressure2:
            # Check for 'height' variables
            if 'zgrid' not in src.variables:
                raise KeyError("Variable 'zgrid(height)' is required but not found in the input file.")

            height = src.variables['zgrid'][:]
            pressure2 = calculate_pressure2(pressure, height, nCells, nVertLevelsP1, len(xtime))
        

        for var_name in variables:
            print(f'  Working on: {var_name}')
            if var_name not in src.variables:
                print(f"Warning: {var_name} not found in the input file.")
                continue

            var_in = src.variables[var_name]
            units = getattr(var_in, 'units', '')
            long_name = getattr(var_in, 'long_name', '')

            # Check if the variable has nVertLevelsP1 (or nVertLevels)
            if 'nVertLevelsP1' in var_in.dimensions:  # Variable with nVertLevelsP1
                print(f"{var_name} has nVertLevelsP1, calculating pressure2.")
                pressure_in = pressure2
                nLevels_in = nVertLevelsP1
            else:
                pressure_in = pressure
                nLevels_in = nVertLevels

            print(f'   Creating variables at fixed pressure levels...')
            levs_in = np.array(levs_hPa) * 100  # Convert hPa to Pa

            for i, lev in enumerate(levs_hPa):
                var_out_name = generate_new_var_name(var_name, int(lev))
                var_out = dst.createVariable(var_out_name, 'f', dimensions=('Time', 'nCells'), fill_value=fill_val)
                var_out.setncattr('units', units)
                var_out.setncattr('long_name', f'{long_name}, interpolated to {lev} hPa')

            print(f'   Interpolating {var_name} across times')
            for t in range(len(xtime)):
                print(f"     Interpolating for time step {t}")
                field_in = src.variables[var_name][t, :, ::-1]

                field_out = interp_tofixed_pressure(
                    nCells, nLevels_in, len(levs_hPa), pressure_in[t, :, ::-1], field_in,
                    np.tile(levs_in, (nCells, 1))[:, ::-1])[:, ::-1]

                for j, lev in enumerate(levs_hPa):
                    var_out_name = generate_new_var_name(var_name, int(lev))
                    print(f'writing {var_out_name}')
                    dst.variables[var_out_name][t, :] = field_out[:, j]

def main():
    """
    Vertically interpolate MPAS-Atmosphere fields to a specified set
    of isobaric levels. The interpolation is linear in log-pressure.

    Variables to be set in this script include:
        - levs_hPa : a list of isobaric levels, in hPa
        - field_names : a list of names of fields to be vertically interpolated
                        these fields must be dimensioned by ('Time', 'nCells', 'nVertLevels')
                        or ('Time', 'nCells', 'nVertLevelsP1')
        - fill_val : a value to use in interpolated fields to indicate values below
                    the lowest model layer midpoint or above the highest model layer midpoint
        - input_files: a list of or at least one input netcdf file containing the [field_names]
                    to be interpolated to fixed pressure levels and their respective dimensions
    """
    #==============================================================================
    # Set default values
    # Populate 3-d variables to interpolate to fixed pressure levels
    #
    default_vars = ['uReconstructZonal', 'uReconstructMeridional', 'ertel_pv']
    default_plevs = [1000.0, 925.0, 850.0, 700.0, 600.0, 500.0, 400.0, 300.0, 250.0, 200.0, 
                     150.0, 100.0, 70.0, 50.0, 30.0, 20.0, 10.0, 5.0, 1.0]
    
    parser = argparse.ArgumentParser(
        description="""
        Interpolates specified MPAS model variables to fixed pressure levels.

        This script processes MPAS netCDF files, interpolating selected 3D fields 
        to specified pressure levels, and saves the results as new variables in output 
        files. It supports multiprocessing for handling multiple files in parallel.

        Example usage:
          python mpas_isobaric_interp.py -v uReconstructZonal -v uReconstructMeridional -p 1000 -p 500 \
          --num_processors 4 input_file1.nc input_file2.nc ....
        """,
        formatter_class=argparse.RawTextHelpFormatter
    )
    
    parser.add_argument(
        '-v', '--variables', nargs='?', action='append', type=str,
        help="List of variables to interpolate. If not provided, default variables are used."
    )
    parser.add_argument(
        '-p', '--pressure_levels', action='append', nargs='?', type=float,
        help="List of pressure levels (in hPa) to interpolate to. Defaults are common pressure levels."
    )
    parser.add_argument(
        '-f', '--fill_value', type=float, default=-1.0e34,
        help="Optional fill value for interpolated data. Default is -1.0e34."
    )
    parser.add_argument(
        '--num_processors', type=int, default=1,
        help="Number of processors for parallel processing. Default is 1 (no parallelism)."
    )
    parser.add_argument(
        'input_files', nargs='+', type=str,
        help="List of input MPAS diag or history netCDF files to process."
    )
    
    args = parser.parse_args()

    # Ensure input files and variables are not empty
    if not args.input_files:
        raise ValueError("Please provide at least one input file.")
    if not args.variables:
        args.variables = default_vars
    if not args.pressure_levels:
        args.pressure_levels = default_plevs

    # Trim all potential whitespaces 
    args.variables = [str.strip(var) for var in args.variables]
    args.input_files = [str.strip(file) for file in args.input_files]

    # Multiprocessing setup
    tasks = [(input_file, f"iso_{os.path.basename(input_file)}", args.variables, args.pressure_levels, args.fill_value) for input_file in args.input_files]
    if args.num_processors > 1:
        with Pool(args.num_processors) as pool:
            pool.starmap(interpolate_and_save, tasks)
    else:
        for task in tasks:
            interpolate_and_save(*task)

if __name__ == "__main__":
    main()
