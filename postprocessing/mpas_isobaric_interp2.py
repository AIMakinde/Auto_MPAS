import netCDF4 as nc
import numpy as np

def read_nc_var(dataset, var_name):
    """ Utility to read a variable from the netCDF dataset safely """
    if var_name in dataset.variables:
        return dataset.variables[var_name][:]
    else:
        raise KeyError(f"Variable '{var_name}' not found in the dataset.")

def compute_dewpoint(pressure, qv):
    """ Compute dewpoint temperature """
    evp = pressure * qv / (qv + 0.622)
    evp = np.maximum(evp, 1.0e-8)
    dewpoint = (243.5 * np.log(evp / 6.112)) / (17.67 - np.log(evp / 6.112)) + 273.15
    return dewpoint

import numpy as np

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
    field_out = np.full((ncol, nlev_out), np.nan) # Initialize field_out to NaN

    for k in range(nlev_out):
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


def isobaric_diagnostics(init_file, diag_file):
    init_ds = nc.Dataset(init_file, 'r')
    diag_ds = nc.Dataset(diag_file, 'r')

    # Reading necessary variables from diag.nc
    nCells = init_ds.dimensions['nCells'].size
    nVertLevels = diag_ds.dimensions['nVertLevels'].size
    
    pressure = read_nc_var(diag_ds, 'pressure')  # Using pressure directly from diag.nc
    temperature = read_nc_var(diag_ds, 'temperature')  # Using available temperature
    # qv = read_nc_var(diag_ds, 'scalars')  # Using available scalars for specific humidity
    
    # # Calculate dewpoint
    # dewpoint = compute_dewpoint(pressure, qv)

    # Define pressure levels to interpolate to
    pressure_levels = [50.0, 100.0, 200.0, 250.0, 500.0, 700.0, 850.0, 925.0]

    # Interpolate temperature, dewpoint, and other necessary fields
    temperature_interp = interpolate_to_pressure_levels(nCells, nVertLevels, temperature, pressure, pressure_levels)
    # dewpoint_interp = interpolate_to_pressure_levels(nCells, nVertLevels, dewpoint, pressure, pressure_levels)

    # Output the results as a new netCDF file
    with nc.Dataset('output_diagnostics.nc', 'w', format='NETCDF4') as out_ds:
        out_ds.createDimension('nCells', nCells)
        out_ds.createDimension('levels', len(pressure_levels))

        temp_var = out_ds.createVariable('temperature_interp', 'f4', ('nCells', 'levels'))
        # dewpoint_var = out_ds.createVariable('dewpoint_interp', 'f4', ('nCells', 'levels'))

        temp_var[:, :] = temperature_interp
        # dewpoint_var[:, :] = dewpoint_interp

if __name__ == "__main__":
    try:
        init_file = 'x1.163842.grid.nc'
        diag_file = 'history.2022-04-07_06.00.00.nc'
        isobaric_diagnostics(init_file, diag_file)
    except KeyError as e:
        print(e)