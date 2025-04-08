#!/usr/bin/env python
"""
This script processes SST data from NetCDF files by comparing each grid point to a zonal average,
and, for grid points that exceed (zonal average + threshold), replaces their value according to one 
of three modes:
    1) "constant":             Replace with a constant value.
    2) "constant_plus_avg":      Replace with (zonal average + constant).
    3) "value_plus_constant":    Replace with (original value + constant).

Processing parameters (region, threshold, replacement mode/value, plotting options, etc.) are 
read from a YAML configuration file named 'config.filter' located in the same directory as the script.
SST input files must be provided as command-line arguments.

Usage:
    python agulhas_filter_nc.py sst_file1.nc sst_file2.nc ...

Example config.filter:

----------------------------------------
region:
  lon_min: -20.0
  lon_max: 10.0
  lat_min: -40.0
  lat_max: -30.0

processing:
  threshold: 0.5  # Grid points exceeding (zonal average + threshold) will be modified.
  replacement:
    mode: "constant_plus_avg"   # Options: "constant", "constant_plus_avg", "value_plus_constant"
    value: -1.0                 # The constant value to use in the replacement.
  plot: true
  num_procs: 2

sst:
  varname: "sst"  # Optional; default is "sst"

# Optional: if specified, this LSM file will be used for all SST files.
# If omitted, each SST file is assumed to contain the LSM variable.
lsm:
  file: "lsm_file.nc"  # Optional
  varname: "lsm"       # Optional; default is "lsm"
----------------------------------------
"""

import os
import sys
import yaml
import xarray as xr
import numpy as np
import matplotlib.pyplot as plt
from multiprocessing import Pool

def process_netcdf(sst_input, lsm_input, output_nc,
                   lon_min, lon_max, lat_min, lat_max,
                   threshold, rep_mode, rep_value, plot,
                   sst_varname="sst", mask_varname="lsm", buffer=8):
    """
    Process a single SST file using the LSM file for masking.
    For grid points exceeding (zonal average + threshold), replace them based on the selected mode:
      - "constant":             new value = rep_value
      - "constant_plus_avg":      new value = zonal average + rep_value
      - "value_plus_constant":    new value = original value + rep_value
    """
    try:
        # Open datasets
        ds_sst = xr.open_dataset(sst_input)
        ds_lsm = xr.open_dataset(lsm_input)

        # Ensure required variables exist
        if sst_varname not in ds_sst.variables:
            raise ValueError(f"SST variable '{sst_varname}' not found in {sst_input}!")
        if mask_varname not in ds_lsm.variables:
            raise ValueError(f"LSM variable '{mask_varname}' not found in {lsm_input}!")

        sst = ds_sst[sst_varname]
        mask = ds_lsm[mask_varname]

        # Apply land-sea mask (assumes 0 = water, 1 = land)
        sst_masked = sst.where(mask == 0)

        # Select the processing region (note: latitude order may depend on dataset conventions)
        sst_masked_region = sst_masked.sel(longitude=slice(lon_min, lon_max),
                                           latitude=slice(lat_max, lat_min))
        sst_region = sst.sel(longitude=slice(lon_min, lon_max),
                             latitude=slice(lat_max, lat_min))

        # Compute zonal average on the masked region and broadcast to the region shape
        zonal_avg = sst_masked_region.mean(dim="longitude")
        zonal_avg_broadcast = zonal_avg.broadcast_like(sst_region)

        # Compute the replacement value based on the selected mode.
        if rep_mode == "constant":
            replacement_val = rep_value
        elif rep_mode == "constant_plus_avg":
            replacement_val = zonal_avg_broadcast + rep_value
        elif rep_mode == "value_plus_constant":
            replacement_val = sst_region + rep_value
        else:
            raise ValueError(f"Invalid replacement mode: {rep_mode}")

        # Replace grid points where sst > (zonal average + threshold)
        sst_processed = xr.where(sst_region > zonal_avg_broadcast + threshold,
                                 replacement_val, sst_region)

        # Update SST data in the original dataset for the selected region
        sst_updated = sst.copy()
        sst_updated.loc[dict(longitude=slice(lon_min, lon_max),
                             latitude=slice(lat_max, lat_min))] = sst_processed

        # Save updated dataset to output file
        ds_sst["sst_updated"] = sst_updated
        ds_sst.to_netcdf(output_nc, mode="w")
        print(f"Processed {sst_input} successfully. Output saved to {output_nc}")

        if plot:
            sst_difference = sst_region - sst_processed
            plot_sst_comparison(os.path.basename(sst_input), sst_region, sst_processed,
                                sst_difference, lon_min, lon_max, lat_min, lat_max)
    except Exception as e:
        print(f"Error processing {sst_input}: {e}")




def plot_sst_comparison(plot_suffix, sst_original, sst_mod, sst_difference,
                        lon_min, lon_max, lat_min, lat_max):
    """
    Plot the comparison between original and processed SST, and their difference.
    """
    sst_levels = np.arange(271, 302, 1)  # Temperature levels from 271K to 302K
    diff_levels = np.linspace(-10, 10, 21)  # Difference levels from -10K to 10K

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))
    sst_original.plot(ax=axes[0], levels=sst_levels, cmap="coolwarm",
                      cbar_kwargs={"label": "Temperature (K)"})
    axes[0].set_title("Original SST")
    axes[0].grid(True)

    sst_mod.plot(ax=axes[1], levels=sst_levels, cmap="coolwarm",
                 cbar_kwargs={"label": "Temperature (K)"})
    axes[1].set_title("Processed SST")
    axes[1].grid(True)

    sst_difference.plot(ax=axes[2], levels=diff_levels, cmap="bwr",
                        cbar_kwargs={"label": "Temp Diff (K)"})
    axes[2].set_title("Difference (Original - Processed)")
    axes[2].grid(True)

    plt.tight_layout()
    plot_filename = f"sst_comparison_plot_{plot_suffix}.png"
    plt.savefig(plot_filename)
    print(f"Plot saved as {plot_filename}")



def process_file(args):
    """
    Unpack arguments for multiprocessing.
    """
    (sst_input, lsm_input, output_nc,
     lon_min, lon_max, lat_min, lat_max,
     threshold, rep_mode, rep_value, plot,
     sst_varname, mask_varname) = args
    process_netcdf(sst_input, lsm_input, output_nc,
                   lon_min, lon_max, lat_min, lat_max,
                   threshold, rep_mode, rep_value, plot,
                   sst_varname, mask_varname)



def load_config(config_path):
    """
    Load the YAML configuration file.
    """
    with open(config_path, "r") as f:
        config = yaml.safe_load(f)
    return config



if __name__ == "__main__":
    # Locate the configuration file (config.filter in the same directory as the script)
    script_dir = os.path.dirname(os.path.abspath(__file__))
    config_file = os.path.join(script_dir, "config.filter")
    if not os.path.exists(config_file):
        print(f"Error: Configuration file {config_file} not found!")
        sys.exit(1)

    # Load configuration from YAML
    config = load_config(config_file)

    # Check that at least one SST file is provided as an argument.
    if len(sys.argv) < 2:
        print("Usage: python agulhas_filter_nc.py sst_file1.nc [sst_file2.nc ...]")
        sys.exit(1)
    sst_files = sys.argv[1:]

    # Extract region parameters
    region_conf = config.get("region", {})
    lon_min = region_conf.get("lon_min")
    lon_max = region_conf.get("lon_max")
    lat_min = region_conf.get("lat_min")
    lat_max = region_conf.get("lat_max")
    if None in (lon_min, lon_max, lat_min, lat_max):
        print("Error: Region parameters (lon_min, lon_max, lat_min, lat_max) must be specified in the config.filter.")
        sys.exit(1)

    # Extract processing parameters
    proc_conf = config.get("processing", {})
    threshold = proc_conf.get("threshold", 0.0)
    rep_conf = proc_conf.get("replacement", {})
    rep_mode = rep_conf.get("mode", "constant_plus_avg")
    rep_value = rep_conf.get("value", 0.0)
    plot = proc_conf.get("plot", False)
    num_procs = proc_conf.get("num_procs", 1)

    # SST variable configuration (only variable name is specified in the YAML)
    sst_conf = config.get("sst", {})
    sst_varname = sst_conf.get("varname", "sst")

    # LSM configuration: use the provided LSM file if specified; otherwise, assume each SST file contains the LSM variable.
    lsm_conf = config.get("lsm", {})
    lsm_file = lsm_conf.get("file", None)
    mask_varname = lsm_conf.get("varname", "lsm")

    # Build processing tasks for each SST file.
    tasks = []
    for sst_file in sst_files:
        current_lsm_file = lsm_file if lsm_file is not None else sst_file
        output_nc = f"mod_{os.path.basename(sst_file)}"
        tasks.append((
            sst_file, current_lsm_file, output_nc,
            lon_min, lon_max, lat_min, lat_max,
            threshold, rep_mode, rep_value, plot, sst_varname, mask_varname
        ))

    # Process files in parallel.
    with Pool(processes=num_procs) as pool:
        pool.map(process_file, tasks)
