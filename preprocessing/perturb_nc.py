import yaml
from netCDF4 import Dataset
import numpy as np
from multiprocessing import Pool
import os

# Define possible names for latitude, longitude, time, and level dimensions
LAT_NAMES = {"latitude", "lat"}
LON_NAMES = {"longitude", "long", "lon"}
TIME_NAMES = {"time", "valid_time"}
LEVEL_NAMES = {"level", "pressure_level"}


def find_variable_by_name(nc, possible_names):
    """Find a variable in a NetCDF file by matching from a set of possible names."""
    for var in nc.variables:
        if var.lower() in possible_names:
            return var
    raise ValueError(f"None of the variable names {possible_names} was found in the NetCDF file.")


def modify_grid_points(params):
    """
    Modify multiple grid points in a NetCDF file.

    Parameters:
    - file_path (str): Path to the NetCDF file to modify.
    - perturbations (list): List of dictionaries with 'lat', 'lon', and 'constant' keys.
    - target_time (int): Target time index.
    - target_level (int): Target level index.
    - variable_name (str): Name of the variable to modify.

    Returns:
    - str: Result message for the processed file.
    """
    file_path, perturbations, target_time, target_level, variable_name = params

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

            # Access the target variable (case insensitive)
            target_var = next((var for var in nc.variables if var.lower() == variable_name.lower()), None)
            if target_var is None:
                raise ValueError(f"Variable '{variable_name}' not found in the NetCDF file.")

            # Access the target variable's data
            data = nc.variables[target_var][:]
            index = [slice(None)] * data.ndim  # Create slices for all dimensions

            # Dynamically adjust for time and level dimensions
            if time_var and time_var in nc.variables[target_var].dimensions:
                index[nc.variables[target_var].dimensions.index(time_var)] = target_time
            if level_var and level_var in nc.variables[target_var].dimensions:
                index[nc.variables[target_var].dimensions.index(level_var)] = target_level

            # Modify each perturbation location
            for perturbation in perturbations:
                lat_idx = np.abs(lat - perturbation["lat"]).argmin()
                lon_idx = np.abs(lon - perturbation["lon"]).argmin()
                index[-2] = lat_idx
                index[-1] = lon_idx
                nc.variables[target_var][tuple(index)] += perturbation["constant"]

        return f"Modified {file_path} successfully."
    except Exception as e:
        return f"Error processing {file_path}: {e}"


def process_files(perturbations, target_time, target_level, variable_name, num_processors, input_files):
    """Process multiple NetCDF files in parallel."""
    params = [
        (file, perturbations, target_time, target_level, variable_name) for file in input_files
    ]

    with Pool(num_processors) as pool:
        results = pool.map(modify_grid_points, params)

    for result in results:
        print(result)


if __name__ == "__main__":
    import argparse

    # Define the default target locations file
    TARGET_LOC_FILE = "target_locs.perturb"

    # Check if the target locations file exists
    if not os.path.exists(TARGET_LOC_FILE):
        print(f"Error: Target locations file '{TARGET_LOC_FILE}' not found. Please create the file and try again.")
        exit(1)

    # Load perturbation locations from the YAML file
    with open(TARGET_LOC_FILE, "r") as f:
        perturbations = yaml.safe_load(f)

    # Define command-line arguments
    parser = argparse.ArgumentParser(description="Modify multiple grid points in NetCDF files.")
    parser.add_argument("variable", type=str, help="Name of the variable to modify (case-insensitive).")
    parser.add_argument("--time", type=int, default=0, help="Target time index.")
    parser.add_argument("--level", type=int, default=0, help="Target level index.")
    parser.add_argument("--processors", type=int, default=1, help="Number of processors for parallel processing.")
    parser.add_argument("files", nargs="+", help="List of NetCDF files to process.")

    # Parse arguments
    args = parser.parse_args()

    # Process files
    process_files(
        perturbations=perturbations,
        target_time=args.time,
        target_level=args.level,
        variable_name=args.variable,
        num_processors=args.processors,
        input_files=args.files
    )
