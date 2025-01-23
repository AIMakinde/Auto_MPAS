from netCDF4 import Dataset
import numpy as np
from multiprocessing import Pool

# Define possible names for latitude, longitude, time, and level dimensions
LAT_NAMES = {"latitude", "lat"}
LON_NAMES = {"longitude", "long", "lon"}
TIME_NAMES = {"time", "valid_time"}
LEVEL_NAMES = {"level", "pressure_level"}


def find_variable_by_name(nc, possible_names):
    """
    Find a variable in a NetCDF file by matching from a set of possible names.

    Parameters:
    - nc (Dataset): The NetCDF dataset.
    - possible_names (set): A set of possible variable names.

    Returns:
    - str: The matched variable name.
    """
    for var in nc.variables:
        if var.lower() in possible_names:
            return var
    raise ValueError(f"None of the variable names {possible_names} was found in the NetCDF file.")


def modify_grid_point(params):
    """
    Modify a specific grid point in a NetCDF file by adding a constant value.

    Parameters:
    - file_path (str): Path to the NetCDF file to modify.
    - target_lat (float): Target latitude for the grid point.
    - target_lon (float): Target longitude for the grid point.
    - target_time (int): Target time index.
    - target_level (int): Target level index.
    - constant (float): Constant value to add to the grid point.
    - variable_name (str): Name of the variable to modify.

    Returns:
    - str: Result message for the processed file.
    """
    file_path, target_lat, target_lon, target_time, target_level, constant, variable_name = params

    try:
        # Open file in append mode
        with Dataset(file_path, "r+") as nc:
            # Identify latitude, longitude, time, and level variable names
            lat_var = find_variable_by_name(nc, LAT_NAMES)
            lon_var = find_variable_by_name(nc, LON_NAMES)
            time_var = find_variable_by_name(nc, TIME_NAMES) if any(name in nc.variables for name in TIME_NAMES) else None
            level_var = find_variable_by_name(nc, LEVEL_NAMES) if any(name in nc.variables for name in LEVEL_NAMES) else None

            # Identify the latitude, longitude, and target variable arrays
            lat = nc.variables[lat_var][:]
            lon = nc.variables[lon_var][:]

            # Find nearest grid point indices
            lat_idx = np.abs(lat - target_lat).argmin()
            lon_idx = np.abs(lon - target_lon).argmin()

            # Access the target variable (case insensitive)
            target_var = next((var for var in nc.variables if var.lower() == variable_name.lower()), None)
            if target_var is None:
                raise ValueError(f"Variable '{variable_name}' not found in the NetCDF file.")

            # Access and modify the specific grid point
            data = nc.variables[target_var][:]
            index = [slice(None)] * data.ndim  # Create slices for all dimensions

            # Dynamically adjust for time and level dimensions
            if time_var and time_var in nc.variables[target_var].dimensions:
                index[nc.variables[target_var].dimensions.index(time_var)] = target_time
            if level_var and level_var in nc.variables[target_var].dimensions:
                index[nc.variables[target_var].dimensions.index(level_var)] = target_level

            # Latitude and longitude indices
            index[-2] = lat_idx
            index[-1] = lon_idx

            # Modify the grid point
            nc.variables[target_var][tuple(index)] += constant

        return f"Modified {file_path} successfully."
    except Exception as e:
        return f"Error processing {file_path}: {e}"


def process_files(target_lat, target_lon, target_time, target_level, constant, variable_name, num_processors, input_files):
    """
    Process multiple NetCDF files in parallel.

    Parameters:
    - target_lat (float): Target latitude for the grid point.
    - target_lon (float): Target longitude for the grid point.
    - target_time (int): Target time index.
    - target_level (int): Target level index.
    - constant (float): Constant value to add to the grid point.
    - variable_name (str): Name of the variable to modify.
    - num_processors (int): Number of processors to use.
    - input_files (list): List of NetCDF file paths to process.

    Returns:
    - None
    """
    # Create parameter list for multiprocessing
    params = [
        (file, target_lat, target_lon, target_time, target_level, constant, variable_name) for file in input_files
    ]

    # Use a pool of workers to process files in parallel
    with Pool(num_processors) as pool:
        results = pool.map(modify_grid_point, params)

    # Print results
    for result in results:
        print(result)


if __name__ == "__main__":
    import argparse

    # Define command-line arguments
    parser = argparse.ArgumentParser(description="Modify a specific grid point in NetCDF files.")
    parser.add_argument("variable", type=str, help="Name of the variable to modify (case-insensitive).")
    parser.add_argument("constant", type=float, help="Constant value to add to the grid point.")
    parser.add_argument("lat", type=float, help="Target latitude for the grid point.")
    parser.add_argument("lon", type=float, help="Target longitude for the grid point.")
    parser.add_argument("--time", type=int, default=0, help="Target time index.")
    parser.add_argument("--level", type=int, default=0, help="Target level index.")
    parser.add_argument("--processors", type=int, default=1, help="Number of processors for parallel processing.")
    parser.add_argument("files", nargs="+", help="List of NetCDF files to process.")

    # Parse arguments
    args = parser.parse_args()

    # Process files
    process_files(
        target_lat=args.lat,
        target_lon=args.lon,
        target_time=args.time,
        target_level=args.level,
        constant=args.constant,
        variable_name=args.variable,
        num_processors=args.processors,
        input_files=args.files
    )
