import numpy as np
import xarray as xr
import pywinter.winter as pyw
import subprocess
import argparse
import yaml
from pathlib import Path
from multiprocessing import Pool


# Gravity constant
g = 9.80665

def process_file(args):

    # Unpack input arguments
    inputnc, outprefix, outvars, defaultunits, convert_gh = args

    try:
        # Read NetCDF file
        ds = xr.open_dataset(inputnc)

        # Handle flexible dimension names
        lat_dim = [dim for dim in ['lat', 'latitude'] if dim in ds]
        lon_dim = [dim for dim in ['lon', 'longitude'] if dim in ds]
        time_dim = [dim for dim in ['valid_time', 'time'] if dim in ds]

        if not lat_dim or not lon_dim or not time_dim:
            raise ValueError(f"Required dimensions (latitude, longitude, time) not found in the dataset: {inputnc}")

        lat = ds[lat_dim[0]][:]
        lon = ds[lon_dim[0]][:]
        time = ds[time_dim[0]]
        time_str = [str(i)[:19].replace('T', '_') for i in time.values]
        outnames = [outprefix + ':' + str(i)[:13].replace('T', '_') for i in time.values]

        # Initialize variables
        pl_layer = None
        if 'plevel_variables' in outvars and outvars['plevel_variables']:
            level_dim = [dim for dim in ['pressure_level', 'level', 'levels', 'plev'] if dim in ds]
            if level_dim:
                pl_layer = ds[level_dim[0]].values  # Extract pressure levels
                pl_layer = pl_layer * 100           # Convert to Pa
            else:
                raise ValueError(f"Pressure level dimension not found for pressure level variables in the dataset: {inputnc}")

        sl_layer = ['000007', '007028', '028100', '100255']
        dlat = lat[1] - lat[0]
        dlon = lon[1] - lon[0]
        geo = pyw.Geo0(lat[0], lon[0], dlat, dlon)

        # Loop through each time step
        for i in range(len(time_str)):
            total_var = []

            # Process 3D Variables
            if 'plevel_variables' in outvars and outvars['plevel_variables']:
                for gvar, dvar in outvars['plevel_variables'].items():
                    if dvar in ds:
                        # Geopotential Height from m^2/s^2 to m by dividing with gravity
                        if convert_gh and gvar == 'GHT':
                            print(f"***WARNING: Converting geopotential height ({dvar}) to meters (m)***")
                            data = ds[dvar].values / g
                        else:
                            data = ds[dvar].values
                        winter_d3 = pyw.V3dp(gvar, data[i, :, :, :], pl_layer, unit=defaultunits[gvar])
                        total_var.append(winter_d3)
                    else:
                        print(f"Pressure level variable, {dvar}, not found in the dataset: {inputnc}")

            # Process Surface Variables
            if 'surface_variables' in outvars and outvars['surface_variables']:
                for gvar, dvar in outvars['surface_variables'].items():
                    if dvar in ds:
                        data = ds[dvar].values
                        winter_d2 = pyw.V2d(gvar, data[i, :, :], unit=defaultunits[gvar])
                        total_var.append(winter_d2)
                    else:
                        print(f"Surface variable, {dvar}, not found in the dataset: {inputnc}")

            # Process Soil Layer Variables
            if 'soil_layers' in outvars and outvars['soil_layers']:
                winter_sl_st = np.empty((len(sl_layer), len(lat), len(lon)))
                winter_sl_sm = np.empty((len(sl_layer), len(lat), len(lon)))
                winter_sl_st[:] = np.nan
                winter_sl_sm[:] = np.nan
                sm_track = 0
                st_track = 0

                for gvar, dvar in outvars['soil_layers'].items():
                    if dvar in ds:
                        j = int(gvar[-1])  # Extract layer index from variable name
                        svar = gvar[:-1]
                        data = ds[dvar].values
                        if svar == 'SM':
                            winter_sl_sm[j - 1, :, :] = data[i, :, :]
                            sm_track += j
                            if sm_track == 10:  # All soil layers added
                                winter_sl = pyw.Vsl(svar, winter_sl_sm, sl_layer, unit=defaultunits[gvar])
                                total_var.append(winter_sl)
                        elif svar == 'ST':
                            winter_sl_st[j - 1, :, :] = data[i, :, :]
                            st_track += j
                            if st_track == 10:  # All soil layers added
                                winter_sl = pyw.Vsl(svar, winter_sl_st, sl_layer, unit=defaultunits[gvar])
                                total_var.append(winter_sl)
                    else:
                        print(f"Soil Layer Variable {dvar} not found in the dataset: {inputnc}")

            # Write intermediate file if variables were added
            if total_var:
                pyw.cinter(outprefix, time_str[i], geo, total_var)
                subprocess.run(["mv", f"{outprefix}:{time_str[i]}", outnames[i]])

    except Exception as e:
        print(f"Error processing {inputnc}: {e}")

def main():

    default_units = {
        'TT': 'K',                # Air Temperature
        'RH': '%',                # Relative Humidity
        'SPECHUMD': 'kg kg-1',    # Specific humidity
        'UU': 'm s-1',            # Wind U Component
        'VV': 'm s-1',            # Wind V Component
        'GHT': 'm',               # Geopotential height
        'LANDSEA': '0/1 Flag',    # Fraction Land-sea mask 0=water, 1=land
        'PSFC': 'Pa',             # Surface pressure
        'PMSL': 'Pa',             # Mean sea level pressure
        'SKINTEMP': 'K',          # Skin temperature
        'SEAICE': 'fraction',     # Sea-ice fraction
        'SST': 'K',               # Sea surface temperature
        'SOILHGT': 'm',           # Soil height
        'SNOW': 'kg m-2',         # Water equivalent snow depth
        'TAVGSFC': 'K',           # Daily mean of surface air temperature
        'ST1': 'K',               # Soil temperature layer 1
        'ST2': 'K',               # Soil temperature layer 2
        'ST3': 'K',               # Soil temperature layer 3
        'ST4': 'K',               # Soil temperature layer 4
        'SM1': 'm3 m-3',          # Soil moisture layer 1
        'SM2': 'm3 m-3',          # Soil moisture layer 2
        'SM3': 'm3 m-3',          # Soil moisture layer 3
        'SM4': 'm3 m-3'           # Soil moisture layer 4
    }

    # Set up argument parser
    parser = argparse.ArgumentParser(description="Convert NetCDF variables to WRF/MPAS intermediate files")
    parser.add_argument("-o", "--outprefix", required=True, help="Output prefix for intermediate files")
    parser.add_argument("-p", "--parallel", type=int, default=4, help="Number of parallel processes (default: 4)")
    parser.add_argument("-cg", "--convert-gh", action="store_true", default=False, help="Convert geopotential height from m^2/s^2 to meters")
    parser.add_argument("inputs", nargs='+', help="Path to one or more input NetCDF files")
    args = parser.parse_args()

    input_files = args.inputs
    outprefix = args.outprefix
    num_processes = args.parallel
    convert_gh = args.convert_gh
    outvar_file = "include_var.interm"

    # Read variable mapping from YAML file
    with open(outvar_file, 'r') as f:
        outvars = yaml.safe_load(f)

    # Prepare arguments for each file
    tasks = [
        (
            input_file,
            outprefix,
            outvars,
            default_units,
            convert_gh
        )
        for input_file in input_files
    ]

    # Process files in parallel
    with Pool(processes=num_processes) as pool:
        pool.map(process_file, tasks)

if __name__ == "__main__":
    main()
