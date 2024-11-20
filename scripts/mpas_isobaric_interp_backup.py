import numpy as np
from scipy.interpolate import interp1d
from netCDF4 import Dataset

def interp_tofixed_pressure(nTimes, nCells, nVertLevels, nIntP, press_in, field_in, press_interp):
    """
    Interpolate both pressure and a given field to fixed pressure levels.

    Parameters:
    - nTimes (int): Number of time steps.
    - nCells (int): Number of cells (horizontal dimension).
    - nVertLevels (int): Number of vertical levels.
    - nIntP (int): Number of pressure levels to interpolate to.
    - press_in (ndarray): Input pressure values, shape (nTimes, nCells, nVertLevels).
    - field_in (ndarray): Input field values (e.g., uReconstructZonal), shape (nTimes, nCells, nVertLevels).
    - press_interp (ndarray): Pressure levels to interpolate to, shape (nIntP).

    Returns:
    - field_interp (ndarray): Interpolated field values at the given pressure levels, shape (nTimes, nCells, nIntP).
    - press_interp_out (ndarray): Interpolated pressure values at the given pressure levels, shape (nTimes, nCells, nIntP).
    """
    # Initialize the interpolated field and pressure arrays
    field_interp = np.zeros((nTimes, nCells, nIntP))
    press_interp_out = np.zeros((nTimes, nCells, nIntP))
    
    # Loop through each time step and cell to perform interpolation
    for iTime in range(nTimes):
        for iCell in range(nCells):
            # Interpolate the pressure values for the current cell and time
            press_interp_func = interp1d(press_in[iTime, iCell, :], press_in[iTime, iCell, :], 
                                         bounds_error=False, fill_value="extrapolate")
            press_interp_out[iTime, iCell, :] = press_interp_func(press_interp)

            # Interpolate the field values (uReconstructZonal) for the current cell and time
            field_interp_func = interp1d(press_in[iTime, iCell, :], field_in[iTime, iCell, :], 
                                         bounds_error=False, fill_value="extrapolate")
            field_interp[iTime, iCell, :] = field_interp_func(press_interp)
    
    return field_interp, press_interp_out

def save_to_netcdf(output_file, field_interp, press_interp_out, fixed_pressures, time_values, cell_ids):
    """
    Save interpolated field and pressure data to a NetCDF file.

    Parameters:
    - output_file (str): Path to the output NetCDF file.
    - field_interp (ndarray): Interpolated field values, shape (nTimes, nCells, nIntP).
    - press_interp_out (ndarray): Interpolated pressure values, shape (nTimes, nCells, nIntP).
    - fixed_pressures (ndarray): Pressure levels used for interpolation, shape (nIntP).
    - time_values (ndarray): Time dimension values.
    - cell_ids (ndarray): Cell IDs for the spatial dimension.
    """
    nTimes, nCells, nIntP = field_interp.shape
    
    # Create a new NetCDF file
    with Dataset(output_file, 'w', format='NETCDF4') as ncfile:
        # Define dimensions
        ncfile.createDimension('Time', nTimes)
        ncfile.createDimension('nCells', nCells)
        ncfile.createDimension('levels', nIntP)
        
        # Define dimension variables
        time_var = ncfile.createVariable('Time', 'f4', ('Time',))
        cells_var = ncfile.createVariable('nCells', 'i4', ('nCells',))
        levels_var = ncfile.createVariable('levels', 'f4', ('levels',))
        
        # Write dimension variable values
        time_var[:] = time_values
        cells_var[:] = cell_ids
        levels_var[:] = fixed_pressures
        
        # Define variables for pressure and interpolated field
        pressure_var = ncfile.createVariable('pressure_interp', 'f4', ('Time', 'nCells', 'levels'))
        field_var = ncfile.createVariable('uReconstructZonal_interp', 'f4', ('Time', 'nCells', 'levels'))
        
        # Add data to variables
        pressure_var[:, :, :] = press_interp_out
        field_var[:, :, :] = field_interp
        
        # Add metadata (optional)
        ncfile.description = 'Interpolated pressure and uReconstructZonal data on fixed isobaric levels'
        pressure_var.units = 'hPa'
        field_var.units = 'm/s'  # Assuming uReconstructZonal is in meters per second
        levels_var.units = 'hPa'
        time_var.units = 'hours since simulation start'
        cells_var.units = 'cell IDs'
        
    print(f"Interpolated data saved to {output_file}")

# Example of loading data from MPAS init.nc and diag.nc files
def load_mpas_data(init_nc_file, diag_nc_file):
    """
    Load state and mesh variables from MPAS .nc files.

    Parameters:
    - init_nc_file (str): Path to the init.nc file.
    - diag_nc_file (str): Path to the diag.nc file.

    Returns:
    - nTimes (int): Number of time steps.
    - nCells (int): Number of cells.
    - nVertLevels (int): Number of vertical levels.
    - press_in (ndarray): Pressure values, shape (nTimes, nCells, nVertLevels).
    - field_in (ndarray): uReconstructZonal values, shape (nTimes, nCells, nVertLevels).
    - time_values (ndarray): Time values for the time dimension.
    - cell_ids (ndarray): Cell IDs for the cell dimension.
    """
    with Dataset(init_nc_file, 'r') as init_nc, Dataset(diag_nc_file, 'r') as diag_nc:
        # Read the dimensions
        nTimes = diag_nc.dimensions['Time'].size
        nCells = diag_nc.dimensions['nCells'].size
        nVertLevels = diag_nc.dimensions['nVertLevels'].size
        
        # Load time values and cell IDs
        time_values = diag_nc.variables['xtime'][:]  # Assuming 'xtime' stores time data
        cell_ids = init_nc.variables['cellID'][:]  # Assuming 'cellID' stores cell identifiers

        # Load pressure and uReconstructZonal data
        press_in = diag_nc.variables['pressure'][:]  # shape: (nTimes, nCells, nVertLevels)
        field_in = diag_nc.variables['uReconstructZonal'][:]  # shape: (nTimes, nCells, nVertLevels)

        return nTimes, nCells, nVertLevels, press_in, field_in, time_values, cell_ids

# Example usage
# Define some fixed pressure levels for interpolation (in hPa)
fixed_pressures = np.array([50, 100, 200, 250, 500, 700, 850, 925])  # Pressure levels in hPa

# Load the data (from init.nc and diag.nc)
nTimes, nCells, nVertLevels, press_in, field_in, time_values, cell_ids = load_mpas_data('x1.163842.grid.nc', 'diag.2022-04-07_00.00.00.nc')

# Perform the interpolation
field_interp, press_interp_out = interp_tofixed_pressure(nTimes=nTimes, nCells=nCells, nVertLevels=nVertLevels, 
                                                         nIntP=len(fixed_pressures),
                                                         press_in=press_in, field_in=field_in,
                                                         press_interp=fixed_pressures)

# Save the interpolated data to a NetCDF file
save_to_netcdf('interpolated_output.nc', field_interp, press_interp_out, fixed_pressures, time_values, cell_ids)
