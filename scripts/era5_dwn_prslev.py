import argparse
import cdsapi
import sys
import multiprocessing
from datetime import datetime, timedelta
from multiprocessing import Pool


# Example variables (time-invariant variables)
lvariables = [
    'geopotential', 'relative_humidity', 'specific_humidity',
    'temperature', 'u_component_of_wind', 'v_component_of_wind',

    'divergence', 'fraction_of_cloud_cover', 'potential_vorticity',
    'specific_cloud_ice_water_content', 'specific_cloud_liquid_water_content',
    'specific_rain_water_content', 'specific_snow_water_content',
    'vertical_velocity', 'vorticity'
    ]

plevels = [
    '1', '2', '3',
    '5', '7', '10',
    '20', '30', '50',
    '70', '100', '125',
    '150', '175', '200',
    '225', '250', '300',
    '350', '400', '450',
    '500', '550', '600',
    '650', '700', '750',
    '775', '800', '825',
    '850', '875', '900',
    '925', '950', '975',
    '1000',
]


def download_era5_day(args):
    start, north, west, south, east, variables, levels, tsteps, format = args

    c = cdsapi.Client()

    # CDS API requires hours to be specified explicitly in a list
    hours = [f'{h:02d}:00' for h in range(0, 24, tsteps)]

    ofile = f'era5_prslv_{start.strftime("%Y%m%d")}.{format}'
    try:
        print(f"  [+] {start}...")
        c.retrieve(
            'reanalysis-era5-pressure-levels',
            {
                'product_type': 'reanalysis',
                'variable': variables,
                'pressure_level': levels,
                'year': start.year,
                'month': f'{start.month:02d}',
                'day': f'{start.day:02d}',
                'time': hours,
                'format': format,
                'area': [north, west, south, east],
            },
            ofile
        )
        print(f'      completed. Data downloaded: {ofile}')
    except Exception as e:
        print(f"Error downloading for time range {start}: {e}")

def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Download ERA5 surface datasets (for MPAS) from Copernicus Climate Data Store over a given time range for multiple variables using multiprocessing."
    )
    
    # Adding command-line arguments for the bounding box, time range, and other parameters
    parser.add_argument('--north', type=float, default=90.0, help='Northern latitude of the bounding box (e.g., 50.0)')
    parser.add_argument('--west', type=float, default=-180.0, help='Western longitude of the bounding box (e.g., -130.0)')
    parser.add_argument('--south', type=float, default=-90.0, help='Southern latitude of the bounding box (e.g., 20.0)')
    parser.add_argument('--east', type=float, default=180.0, help='Eastern longitude of the bounding box (e.g., -60.0)')
    parser.add_argument('--start_time', type=str, required=True, help='Start time in YYYY-MM-DDTHH format (e.g., 2024-09-17T06)')
    parser.add_argument('--end_time', type=str, required=True, help='End time in YYYY-MM-DDTHH format (e.g., 2024-09-19T18)')
    parser.add_argument('--time_step', type=int, required=True, help='Time step in hours (e.g., 6 or 1 hour intervals)')
    parser.add_argument('--format', choices=['netcdf', 'grib'], default='grib', help="Output format (either 'netcdf' or 'grib')")
    parser.add_argument('--num_processes', type=int, default=4, help="Number of parallel processes to use (default is 4)")

    return parser.parse_args()

def generate_time_intervals(start_time, end_time):
    """
    Splits the given time range into daily intervals but ensures partial days
    are handled properly at the start and end of the range.
    """
    intervals = []
    
    current_time = start_time
    while current_time < end_time:
        # Ensure that each interval is from HH:00 on one day to HH:00 on the next
        if current_time.hour == 0:
            next_time = current_time + timedelta(days=1)
        else:
            next_time = current_time.replace(hour=0, minute=0, second=0, microsecond=0) + timedelta(days=1)

        if next_time > end_time:
            next_time = end_time

        # intervals.append((current_time, next_time - timedelta(hours=1)))
        intervals.append(current_time)
        current_time = next_time

    return intervals

if __name__ == "__main__":
    # Parse command-line arguments
    args = parse_arguments()

    # Convert start_time and end_time arguments to datetime objects
    try:
        start_time = datetime.strptime(args.start_time, '%Y-%m-%dT%H')
        end_time = datetime.strptime(args.end_time, '%Y-%m-%dT%H')
    except ValueError:
        print("Invalid time format. Please use 'YYYY-MM-DDTHH' (e.g., 2024-09-17T06).")
        sys.exit(1)

    if start_time >= end_time:
        print("Error: start_time must be before end_time.")
        sys.exit(1)

    # Generate time intervals
    time_intervals = generate_time_intervals(start_time, end_time)

    # Prepare arguments for each time interval download
    download_args = [(start, args.north, args.west, args.south, args.east, lvariables, plevels, args.time_step, args.format) 
                     for start in time_intervals]

    # Try use multiprocessing Pool to download the data for each time interval in parallel
    # Check if the environment supports multiprocessing
    parallelFailed = False
    try:
        # Create a multiprocessing pool with the number of available CPUs
        print(f"Downloading dataset using multiprocessing pool with {args.num_processes} processes.")
        with Pool(args.num_processes) as pool:
            parallelFailed = False
            pool.map(download_era5_day, download_args)
    except Exception as e:
        print(f"Failed to create a multiprocessing pool: {e}")
        parallelFailed = True


    # Try download the data for each time interval in sequence
    if parallelFailed:
        # Download the datasets sequentially
        print(f"Downloading dataset sequentially.")
        for download_arg in download_args:
            download_era5_day(download_arg)
        
