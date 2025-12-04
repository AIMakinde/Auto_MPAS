"""

Download ERA5 pressure-level datasets from the Copernicus Climate Data Store (CDS) over a user-specified time range, region, and set of variables/levels.
Supports grouping downloads by timestep, days, months, or years, and parallel downloading with progress indication.


# Version:  2.2
# Date:     2024-09-13
# Modified: 2025-09-17
# Author:   AI Makinde
# Email:    mckynde@gmail.com

Usage:
    python era5_dwn_prslev.py --start_time 2020-01-01T00 --end_time 2020-01-10T00 --group_by days --group_count 2 --variables temperature u_component_of_wind --levels 1000 850 500

Arguments:
    --north, --west, --south, --east: Bounding box coordinates
    --start_time, --end_time: Time range in YYYY-MM-DDTHH format
    --time_step: Time step in hours
    --format: Output format ('netcdf' or 'grib')
    --out_dir: Output directory
    --num_processes: Number of parallel processes
    --group_by: How to group downloads ('timestep', 'days', 'months', 'years')
    --group_count: Number of days/months/years per file
    --variables: List of ERA5 pressure-level variables
    --levels: List of pressure levels

Requirements:
    - cdsapi
    - tqdm (optional, for progress bar)
"""

import argparse
import sys
from datetime import datetime, timedelta
from dateutil.relativedelta import relativedelta
from multiprocessing import Pool
import logging

try:
    import cdsapi
except ImportError:
    print("cdsapi is required. Install with 'pip install cdsapi'.")
    sys.exit(1)

try:
    from tqdm import tqdm
    TQDM_AVAILABLE = True
except ImportError:
    TQDM_AVAILABLE = False

# Default pressure-level variables and levels
DEFAULT_VARIABLES = [
    'geopotential', 'relative_humidity', 'specific_humidity',
    'temperature', 'u_component_of_wind', 'v_component_of_wind',
    'divergence', 'fraction_of_cloud_cover', 'potential_vorticity',
    'specific_cloud_ice_water_content', 'specific_cloud_liquid_water_content',
    'specific_rain_water_content', 'specific_snow_water_content',
    'vertical_velocity', 'vorticity'
]
DEFAULT_LEVELS = [
    '1', '2', '3', '5', '7', '10', '20', '30', '50', '70', '100', '125', '150', '175', '200',
    '225', '250', '300', '350', '400', '450', '500', '550', '600', '650', '700', '750', '775',
    '800', '825', '850', '875', '900', '925', '950', '975', '1000'
]

def collect_time_components(start, end, tsteps):
    """
    Collects all unique years, months, days, and times within a given interval.
    Returns sorted lists for use in CDS API requests.
    """
    times, years, months, days = set(), set(), set(), set()
    current = start
    while current < end:
        years.add(current.year)
        months.add(f"{current.month:02d}")
        days.add(f"{current.day:02d}")
        times.add(f"{current.hour:02d}:00")
        current += timedelta(hours=tsteps)
    return sorted(years), sorted(months), sorted(days), sorted(times)

def download_era5_prslev_group(args):
    """
    Downloads ERA5 pressure-level data for a given interval, grouping by timestep, days, months, or years.
    """
    start, end, north, west, south, east, variables, levels, tsteps, format, group_by, out_dir = args
    c = cdsapi.Client()
    years, months, days, times = collect_time_components(start, end, tsteps)

    if group_by == 'timestep':
        current = start
        while current < end:
            ofile = f"{out_dir}/era5_prslv_{current.strftime('%Y%m%d%H')}.{format}"
            try:
                print(f"  [+] Downloading {current} ...")
                c.retrieve(
                    'reanalysis-era5-pressure-levels',
                    {
                        'product_type': 'reanalysis',
                        'variable': variables,
                        'pressure_level': levels,
                        'year': current.year,
                        'month': f"{current.month:02d}",
                        'day': f"{current.day:02d}",
                        'time': [f"{current.hour:02d}:00"],
                        'format': format,
                        'area': [north, west, south, east],
                        'download_format': 'unarchived'
                    },
                    ofile
                ).download()
                print(f'      completed. Data downloaded: {ofile}')
            except Exception as e:
                print(f"Error downloading for time {current}: {e}")
                logging.error(f"Error downloading for time {current}: {e}")
            current += timedelta(hours=tsteps)
    else:
        ofile = f"{out_dir}/era5_prslv_{start.strftime('%Y%m%d')}_{(end-timedelta(hours=tsteps)).strftime('%Y%m%d')}.{format}"
        try:
            print(f"  [+] Downloading {start} to {end} ...")
            c.retrieve(
                'reanalysis-era5-pressure-levels',
                {
                    'product_type': 'reanalysis',
                    'variable': variables,
                    'pressure_level': levels,
                    'year': years,
                    'month': months,
                    'day': days,
                    'time': times,
                    'format': format,
                    'area': [north, west, south, east],
                    'download_format': 'unarchived'
                },
                ofile
            )
            print(f'      completed. Data downloaded: {ofile}')
        except Exception as e:
            print(f"Error downloading for time range {start} to {end}: {e}")
            logging.error(f"Error downloading for time range {start} to {end}: {e}")

def parse_arguments():
    """
    Parses command-line arguments for the ERA5 pressure-level downloader.
    """
    parser = argparse.ArgumentParser(
        description="Download ERA5 pressure-level datasets from Copernicus Climate Data Store over a given time range for multiple variables using multiprocessing."
    )
    parser.add_argument('--north', type=float, default=90.0, help='Northern latitude of the bounding box')
    parser.add_argument('--west', type=float, default=-180.0, help='Western longitude of the bounding box')
    parser.add_argument('--south', type=float, default=-90.0, help='Southern latitude of the bounding box')
    parser.add_argument('--east', type=float, default=180.0, help='Eastern longitude of the bounding box')
    parser.add_argument('--start_time', type=str, required=True, help='Start time in YYYY-MM-DDTHH format')
    parser.add_argument('--end_time', type=str, required=True, help='End time in YYYY-MM-DDTHH format')
    parser.add_argument('--time_step', type=int, required=True, help='Time step in hours')
    parser.add_argument('--format', choices=['netcdf', 'grib'], default='grib', help="Output format")
    parser.add_argument('--out_dir', type=str, default='.', help="Output directory for downloaded files")
    parser.add_argument('--num_processes', type=int, default=4, help="Number of parallel processes")
    parser.add_argument('--group_by', choices=['timestep', 'days', 'months', 'years'], default='days',
                        help="How to group downloads into files")
    parser.add_argument('--group_count', type=int, default=1,
                        help="Number of days/months/years per file (ignored for 'timestep')")
    parser.add_argument('--variables', nargs='+', default=DEFAULT_VARIABLES,
                        help="List of ERA5 pressure-level variables to download")
    parser.add_argument('--levels', nargs='+', default=DEFAULT_LEVELS,
                        help="List of pressure levels to download")
    return parser.parse_args()

def generate_time_intervals(start_time, end_time, group_by, group_count, tsteps):
    """
    Generates a list of (start, end) tuples for each download interval.
    """
    intervals = []
    current_time = start_time

    if group_by == 'timestep':
        while current_time < end_time:
            next_time = current_time + relativedelta(hours=tsteps)
            if next_time > end_time:
                next_time = end_time
            intervals.append((current_time, next_time))
            current_time = next_time
    elif group_by == 'days':
        while current_time < end_time:
            next_time = current_time + relativedelta(days=group_count)
            if next_time > end_time:
                next_time = end_time
            intervals.append((current_time, next_time))
            current_time = next_time
    elif group_by == 'months':
        while current_time < end_time:
            year = current_time.year
            month = current_time.month
            for _ in range(group_count):
                if month == 12:
                    year += 1
                    month = 1
                else:
                    month += 1
            next_time = current_time.replace(year=year, month=month, day=1, hour=0)
            if next_time > end_time:
                next_time = end_time
            intervals.append((current_time, next_time))
            current_time = next_time
    elif group_by == 'years':
        while current_time < end_time:
            next_time = current_time.replace(year=current_time.year + group_count, month=1, day=1, hour=0)
            if next_time > end_time:
                next_time = end_time
            intervals.append((current_time, next_time))
            current_time = next_time
    return intervals

def validate_args(args):
    """
    Validates bounding box and time step arguments.
    """
    if not (-90.0 <= args.south < args.north <= 90.0):
        raise ValueError("Invalid latitude bounds.")
    if not (-180.0 <= args.west < args.east <= 180.0):
        raise ValueError("Invalid longitude bounds.")
    if args.time_step < 1 or args.time_step > 24:
        raise ValueError("Invalid time_step. Must be between 1 and 24.")

def main():
    """
    Main entry point for the ERA5 pressure-level downloader.
    """
    logging.basicConfig(filename='log.era5_prslv_download.err', level=logging.ERROR)
    args = parse_arguments()

    try:
        validate_args(args)
        start_time = datetime.strptime(args.start_time, '%Y-%m-%dT%H')
        end_time = datetime.strptime(args.end_time, '%Y-%m-%dT%H')
    except ValueError as e:
        print(f"Argument error: {e}")
        sys.exit(1)

    if start_time >= end_time:
        print("Error: start_time must be before end_time.")
        sys.exit(1)

    intervals = generate_time_intervals(start_time, end_time, args.group_by, args.group_count, args.time_step)
    download_args = [
        (start, end, args.north, args.west, args.south, args.east, args.variables, args.levels, args.time_step, args.format, args.group_by, args.out_dir)
        for start, end in intervals
    ]

    print(f"Preparing to download {len(download_args)} files...")

    parallelFailed = False
    try:
        print(f"Downloading dataset using multiprocessing pool with {args.num_processes} processes.")
        with Pool(args.num_processes) as pool:
            if TQDM_AVAILABLE:
                list(tqdm(pool.imap(download_era5_prslev_group, download_args), total=len(download_args)))
            else:
                pool.map(download_era5_prslev_group, download_args)
    except Exception as e:
        print(f"Failed to create a multiprocessing pool: {e}")
        parallelFailed = True

    if parallelFailed:
        print(f"Downloading dataset sequentially.")
        iterator = tqdm(download_args, desc="Downloading", unit="file") if TQDM_AVAILABLE else download_args
        for download_arg in iterator:
            download_era5_prslev_group(download_arg)

if __name__ == "__main__":
    main()
