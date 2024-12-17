import xarray as xr
import numpy as np
import matplotlib.pyplot as plt
import os
import argparse
from multiprocessing import Pool

def cosine_taper(lon, lat, lon_edge_min, lon_edge_max, lat_edge_min, lat_edge_max, buffer, coord_name):
    """
    Create a cosine taper for smooth blending along one dimension.
    """
    lon_weights = np.ones_like(lon)
    lat_weights = np.ones_like(lat)

    # Combine longitude and latitude weights
    lon_weights_2d, lat_weights_2d = np.meshgrid(lon_weights, lat_weights)
    weights = lon_weights_2d * lat_weights_2d

    # Convert to xarray.DataArray for compatibility
    taper_da = xr.DataArray(weights, dims=['latitude','longitude'], coords={'latitude': lat, 'longitude':lon})

    lon_buffer_min = lon_edge_min - buffer
    lon_buffer_max = lon_edge_max + buffer
    lat_buffer_min = lat_edge_min - buffer
    lat_buffer_max = lat_edge_max + buffer

    # Blend at the lower edge
    left_transition = (lon_weights_2d >= lon_edge_min - buffer) & (lon_weights_2d <= lon_edge_min + buffer) & (lat_weights_2d >= lat_buffer_min) & (lat_weights_2d <= lat_buffer_max)
    right_transition = (lon_weights_2d >= lon_edge_max - buffer) & (lon_weights_2d <= lon_edge_max + buffer) & (lat_weights_2d >= lat_buffer_min) & (lat_weights_2d <= lat_buffer_max)
    bottom_transition = (lat_weights_2d >= lat_edge_min - buffer) & (lat_weights_2d <= lat_edge_min + buffer) & (lon_weights_2d >= lon_buffer_min) & (lon_weights_2d <= lon_buffer_max)
    top_transition = (lat_weights_2d >= lat_edge_max - buffer) & (lat_weights_2d <= lat_edge_max + buffer) & (lon_weights_2d >= lon_buffer_min) & (lon_weights_2d <= lon_buffer_max)

    weights[left_transition] = 0.5 * (1 + np.cos(np.pi * (lon_weights_2d[left_transition] - lon_edge_min) / buffer))
    weights[right_transition] = 0.5 * (1 + np.cos(np.pi * (lon_weights_2d[right_transition] - lon_edge_max) / buffer))

    weights[bottom_transition] = 0.5 * (1 + np.cos(np.pi * (lat_weights_2d[bottom_transition] - lat_edge_min) / buffer))
    weights[top_transition] = 0.5 * (1 + np.cos(np.pi * (lat_weights_2d[top_transition] - lat_edge_max) / buffer))
    
    # Convert to xarray.DataArray for compatibility
    taper_da = xr.DataArray(weights, dims=['latitude','longitude'], coords={'latitude': lat, 'longitude':lon})
    return taper_da

def blend_edges(sst_updated, mask, lon_edge_min, lon_edge_max, lat_edge_min, lat_edge_max, buffer, epsilon=0.01):
    """
    Blend the edges of the modified SST region with the surrounding data for smooth transitions.
    """
    # Extract longitude and latitude coordinates
    lon_2d = sst_updated.coords["longitude"].broadcast_like(sst_updated)
    lat_2d = sst_updated.coords["latitude"].broadcast_like(sst_updated)

    if lon_2d.ndim == 3:
        lon_2d = lon_2d[0, :, :]
        lat_2d = lat_2d[0, :, :]

    # Define buffer regions
    left_buffer_lon = (lon_2d >= lon_edge_min - buffer) & (lon_2d <= lon_edge_min + buffer) & \
                      (lat_2d <= lat_edge_max + buffer) & (lat_2d >= lat_edge_min - buffer)
    right_buffer_lon = (lon_2d >= lon_edge_max - buffer) & (lon_2d <= lon_edge_max + buffer) & \
                       (lat_2d <= lat_edge_max + buffer) & (lat_2d >= lat_edge_min - buffer)
    top_buffer_lat = (lat_2d <= lat_edge_max + buffer) & (lat_2d >= lat_edge_max - buffer) & \
                     (lon_2d >= lon_edge_min - buffer) & (lon_2d <= lon_edge_max + buffer)
    bottom_buffer_lat = (lat_2d <= lat_edge_min + buffer) & (lat_2d >= lat_edge_min - buffer) & \
                        (lon_2d >= lon_edge_min - buffer) & (lon_2d <= lon_edge_max + buffer)

    # Initialize weights with NaNs for land
    weights = xr.where(mask > 0, np.nan, 1).broadcast_like(sst_updated)
    if weights.ndim == 3:
        weights = weights[0, :, :]

    # Adjust weights using linear blending, ensuring weights never reach zero or one
    print("Generating blending weights for left edge...")
    left_weights = xr.where(left_buffer_lon, 
                            epsilon + (1 - 2 * epsilon) * 
                            (lon_2d - (lon_edge_min - buffer)) / (2 * buffer), 
                            weights)

    print("Generating blending weights for right edge...")
    right_weights = xr.where(right_buffer_lon, 
                             epsilon + (1 - 2 * epsilon) * 
                             ((lon_edge_max + buffer) - lon_2d) / (2 * buffer), 
                             left_weights)

    print("Generating blending weights for bottom edge...")
    bottom_weights = xr.where(bottom_buffer_lat, 
                              epsilon + (1 - 2 * epsilon) * 
                              (lat_2d - (lat_edge_min - buffer)) / (2 * buffer), 
                              right_weights)

    print("Generating blending weights for top edge...")
    weights = xr.where(top_buffer_lat, 
                       epsilon + (1 - 2 * epsilon) * 
                       ((lat_edge_max + buffer) - lat_2d) / (2 * buffer), 
                       bottom_weights)

    # Apply the mask once for consistency
    print("Applying mask to blending weights...")
    weights = xr.where(mask > 0, np.nan, weights)

    # Align weights to the full dimensions of sst_updated
    print("Aligning weights to full dataset dimensions...")
    weights = weights.broadcast_like(sst_updated)

    # Perform the blending: interpolate using weighted averages
    print("Blending SST data using weights...")
    blended = (weights * sst_updated) + ((1 - weights) * sst_updated.where(weights.isnull(), 0))

    return blended, weights

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

        # # Apply blending to ensure smooth transitions
        # print("Applying blending to ensure smooth transition...")
        # sst_blended, weights = blend_edges(sst_updated, mask, lon_min, lon_max, lat_min, lat_max, buffer)

        # Update the dataset with the blended SST
        ds["sst_updated"] = sst_updated
        # ds["sst_smoothed"] = sst_blended
        # ds["weights"] = weights

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
