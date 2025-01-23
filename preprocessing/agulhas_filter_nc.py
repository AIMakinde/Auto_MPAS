import xarray as xr
import numpy as np
import matplotlib.pyplot as plt
import os
import argparse
from multiprocessing import Pool


def process_netcdf(input_nc, output_nc, lon_min, lon_max, lat_min, lat_max, threshold, plot, sst_varname="sst", mask_varname="lsm", buffer=8):
    """
    Process a single NetCDF file to modify the SST variable based on zonal averages and apply blending.
    """
    try:
        # Open the NetCDF file
        ds = xr.open_dataset(input_nc)

        # Ensure SST variable exists
        if sst_varname not in ds.variables:
            raise ValueError(f"SST variable (with variable name = '{sst_varname}') not found in the input NetCDF file!")

        # Ensure LSM variable exists
        if mask_varname not in ds.variables:
            raise ValueError(f"Land-Sea Mask variable (with variable name = '{mask_varname}') not found in the input NetCDF file!")

        # Select SST and land-sea mask variables
        sst = ds[sst_varname]
        mask = ds[mask_varname]

        # Mask SST using the land-sea mask (0 = water, 1 = land)
        sst_masked = sst.where(mask == 0)

        # Select the region for processing
        sst_masked_region = sst_masked.sel(longitude=slice(lon_min, lon_max), latitude=slice(lat_max, lat_min))
        sst_region = sst.sel(longitude=slice(lon_min, lon_max), latitude=slice(lat_max, lat_min))

        # Perform zonal averaging
        zonal_avg = sst_masked_region.mean(dim="longitude")

        # Broadcast the zonal average back to the original region shape
        zonal_avg_broadcast = zonal_avg.broadcast_like(sst_region)

        # Apply the threshold condition
        sst_processed = xr.where(sst_region > zonal_avg_broadcast + threshold, zonal_avg_broadcast, sst_region)

        # Replace SST in the original dataset with the processed data
        sst_updated = sst.copy()
        sst_updated.loc[dict(longitude=slice(lon_min, lon_max), latitude=slice(lat_max, lat_min))] = sst_processed

        # Update the dataset with the blended SST
        ds["sst_updated"] = sst_updated

        # Write to the output NetCDF file
        ds.to_netcdf(output_nc, mode="w")

        # Plot the results if enabled
        if plot:
            # Calculate the difference between original and processed SST
            sst_difference = sst_region - sst_processed
            plot_sst_comparison(os.path.basename(input_nc), sst_region, sst_processed, sst_difference, lon_min, lon_max, lat_min, lat_max)

        print(f"Processed {input_nc} successfully. Output saved to {output_nc}")

    except Exception as e:
        print(f"Error processing {input_nc}: {e}")

def plot_sst_comparison(plot_suffix, sst_original, sst_mod, sst_difference, lon_min, lon_max, lat_min, lat_max):
    """
    Plot the SST comparison: original, processed, and difference.
    """
    sst_levels = np.arange(271, 302, 1)  # From 271 K to 302 K with 1 K intervals
    diff_levels = np.linspace(-10, 10, 21)  # Difference levels from -10 to +10 K

    fig, axes = plt.subplots(1, 3, figsize=(18, 6))

    sst_original.plot(ax=axes[0], levels=sst_levels, cmap="coolwarm", cbar_kwargs={"label": "Temperature (K)"})
    axes[0].set_title("Original SST Region")
    axes[0].grid(True)

    sst_mod.plot(ax=axes[1], levels=sst_levels, cmap="coolwarm", cbar_kwargs={"label": "Temperature (K)"})
    axes[1].set_title("Processed SST Region")
    axes[1].grid(True)

    sst_difference.plot(ax=axes[2], levels=diff_levels, cmap="bwr", cbar_kwargs={"label": "Temperature Difference (K)"})
    axes[2].set_title("Difference: Original - Processed")
    axes[2].grid(True)

    plt.tight_layout()
    plt.savefig(f"sst_comparison_plot_{plot_suffix}.png")
    # plt.show()

def process_file(args):
    """
    Wrapper function to allow multiprocessing.
    """
    input_nc, output_nc, lon_min, lon_max, lat_min, lat_max, threshold, plot = args
    process_netcdf(input_nc, output_nc, lon_min, lon_max, lat_min, lat_max, threshold, plot)

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Process SST data in NetCDF files.")
    parser.add_argument("--lon_min", type=float, required=True, help="Minimum longitude for processing")
    parser.add_argument("--lon_max", type=float, required=True, help="Maximum longitude for processing")
    parser.add_argument("--lat_min", type=float, required=True, help="Minimum latitude for processing")
    parser.add_argument("--lat_max", type=float, required=True, help="Maximum latitude for processing")
    parser.add_argument("--threshold", type=float, default=0.0, help="Threshold for replacement (default: 0).")
    parser.add_argument("--plot", action="store_true", default=False, help="Plot the SST comparison")
    parser.add_argument("--num_procs", type=int, default=1, help="Number of processors to use for parallel processing")
    parser.add_argument("input_files", nargs="+", help="Input NetCDF files")

    args = parser.parse_args()

    # Prepare arguments for each file
    tasks = [
        (
            input_file,
            f"mod_{os.path.basename(input_file)}",
            args.lon_min,
            args.lon_max,
            args.lat_min,
            args.lat_max,
            args.threshold,
            args.plot,
        )
        for input_file in args.input_files
    ]

    # Run in parallel using the specified number of processors
    with Pool(processes=args.num_procs) as pool:
        pool.map(process_file, tasks)
