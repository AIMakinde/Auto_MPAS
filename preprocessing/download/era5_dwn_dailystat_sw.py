"""
Download ERA5-Land daily statistics from the Copernicus Climate Data Store (CDS) over a user-specified time range and set of variables.
Supports grouping downloads by days, months, or years, and parallel downloading with progress indication.

Author: Makinde (mckynde@gmail.com)
Created: 2025-09-17
License: MIT

Usage:
    python era5_dwn_daily_sw.py --start_time 2024-01-01T00 --end_time 2024-01-31T00 --group_by days --group_count 7 --variables volumetric_soil_water_layer_1 volumetric_soil_water_layer_2 --daily_statistic daily_mean --frequency 1_hourly

Arguments:
    --start_time, --end_time: Time range in YYYY-MM-DDTHH format
    --group_by: How to group downloads ('days', 'months', 'years')
    --group_count: Number of days/months/years per file
    --variables: List of ERA5-Land variables
    --daily_statistic: Statistic type (e.g., daily_mean, daily_minimum, daily_maximum)
    --frequency: Frequency (e.g., 1_hourly, 3_hourly)
    --time_zone: Time zone (default: utc+00:00)
    --format: Output format ('netcdf' or 'zipped')
    --out_dir: Output directory
    --num_processes: Number of parallel processes

Requirements:
    - cdsapi
    - tqdm (optional, for progress bar)
    - Python 3.7+
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

DEFAULT_VARIABLES = [
    "volumetric_soil_water_layer_1",
    "volumetric_soil_water_layer_2",
    "volumetric_soil_water_layer_3",
    "volumetric_soil_water_layer_4"
]

def collect_time_components(start, end):
    years, months, days = set(), set(), set()
    current = start
    while current < end:
        years.add(str(current.year))
        months.add(f"{current.month:02d}")
        days.add(f"{current.day:02d}")
        current += timedelta(days=1)
    return sorted(years), sorted(months), sorted(days)

def download_era5_land_group(args):
    start, end, north, west, south, east, variables, statistic, frequency, time_zone, format, group_by, out_dir = args
    c = cdsapi.Client()
    years, months, days = collect_time_components(start, end)
    ofile = f"{out_dir}/era5land_{start.strftime('%Y%m%d')}_{(end-timedelta(days=1)).strftime('%Y%m%d')}.{format}"

    try:
        print(f"  [+] Downloading {start} to {end} ...")
        c.retrieve(
            "derived-era5-land-daily-statistics",
            {
                "variable": variables,
                "year": years,
                "month": months,
                "day": days,
                "daily_statistic": statistic,
                "time_zone": time_zone,
                "frequency": frequency,
                "format": format,
                "area": [north, west, south, east]
            },
            ofile
        )
        print(f'      completed. Data downloaded: {ofile}')
    except Exception as e:
        print(f"Error downloading for time range {start} to {end}: {e}")
        logging.error(f"Error downloading for time range {start} to {end}: {e}")

def parse_arguments():
    parser = argparse.ArgumentParser(
        description="Download ERA5-Land daily statistics from Copernicus Climate Data Store over a given time range for multiple variables using multiprocessing."
    )
    parser.add_argument('--north', type=float, default=90.0, help='Northern latitude of the bounding box')
    parser.add_argument('--west', type=float, default=-180.0, help='Western longitude of the bounding box')
    parser.add_argument('--south', type=float, default=-90.0, help='Southern latitude of the bounding box')
    parser.add_argument('--east', type=float, default=180.0, help='Eastern longitude of the bounding box')
    parser.add_argument('--start_time', type=str, required=True, help='Start time in YYYY-MM-DDTHH format (e.g., 2024-01-01T00)')
    parser.add_argument('--end_time', type=str, required=True, help='End time in YYYY-MM-DDTHH format (e.g., 2024-01-31T00)')
    parser.add_argument('--group_by', choices=['days', 'months', 'years'], default='days',
                        help="How to group downloads into files: 'days', 'months', or 'years' per file")
    parser.add_argument('--group_count', type=int, default=1,
                        help="Number of days/months/years per file")
    parser.add_argument('--variables', nargs='+', default=DEFAULT_VARIABLES,
                        help="List of ERA5-Land variables to download")
    parser.add_argument('--daily_statistic', type=str, default='daily_mean',
                        choices=['daily_mean', 'daily_minimum', 'daily_maximum'],
                        help="Daily statistic type")
    parser.add_argument('--frequency', type=str, default='1_hourly',
                        choices=['1_hourly', '3_hourly', '6_hourly'],
                        help="Frequency of statistics")
    parser.add_argument('--time_zone', type=str, default='utc+00:00',
                        help="Time zone (default: utc+00:00)")
    parser.add_argument('--format', choices=['netcdf', 'zipped'], default='netcdf', help="Output format")
    parser.add_argument('--out_dir', type=str, default='.', help="Output directory for downloaded files")
    parser.add_argument('--num_processes', type=int, default=4, help="Number of parallel processes")
    return parser.parse_args()

def generate_time_intervals(start_time, end_time, group_by, group_count):
    intervals = []
    current_time = start_time

    if group_by == 'days':
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

def main():
    logging.basicConfig(filename='log.era5land_download.err', level=logging.ERROR)
    args = parse_arguments()

    try:
        start_time = datetime.strptime(args.start_time, '%Y-%m-%dT%H')
        end_time = datetime.strptime(args.end_time, '%Y-%m-%dT%H')
    except ValueError as e:
        print(f"Argument error: {e}")
        sys.exit(1)

    if start_time >= end_time:
        print("Error: start_time must be before end_time.")
        sys.exit(1)

    intervals = generate_time_intervals(start_time, end_time, args.group_by, args.group_count)
    download_args = [
        (start, end, args.north, args.west, args.south, args.east, args.variables, args.daily_statistic, args.frequency, args.time_zone, args.format, args.group_by, args.out_dir)
        for start, end in intervals
    ]

    print(f"Preparing to download {len(download_args)} files...")

    parallelFailed = False
    try:
        print(f"Downloading dataset using multiprocessing pool with {args.num_processes} processes.")
        with Pool(args.num_processes) as pool:
            if TQDM_AVAILABLE:
                list(tqdm(pool.imap(download_era5_land_group, download_args), total=len(download_args)))
            else:
                pool.map(download_era5_land_group, download_args)
    except Exception as e:
        print(f"Failed to create a multiprocessing pool: {e}")
        parallelFailed = True

    if parallelFailed:
        print(f"Downloading dataset sequentially.")
        iterator = tqdm(download_args, desc="Downloading", unit="file") if TQDM_AVAILABLE else download_args
        for download_arg in iterator:
            download_era5_land_group(download_arg)

if __name__ == "__main__":
    main()
