import cdsapi
import sys


# print out usage
if len(sys.argv) < 3 or (len(sys.argv) > 3 and len(sys.argv) < 7):
    print('')
    print('Usage: python era5_dwn_tinvariant.py <oformat> <global> <lon1> <lon2> <lat1> <lat2>')
    print('')
    print('       Where <oformat> is the format of the output file. Supported formats: "netcdf" & "grb2"')
    print('       <global> is either 1 (download over the whole global, -180:180, -90:90)')
    print('                      or 0 (use specified longitude and latitude domain box')
    print('       <lon1> is the western longitude of the domain box (e.g., -130.0W)')
    print('       <lon2> is the eastern longitude of the domain box (e.g., 20.0E)')
    print('       <lat1> is the northern latitude of the domain box (e.g., 60.0N)')
    print('       <lat2> is the southern latitude of the domain box (e.g., -30.0S)')
    print('')
    exit()


oformat = sys.argv[1]
overglobe = sys.argv[2] == '1'
lon1, lon2, lat1, lat2 = 0

if len(sys.argv) >= 4:
    lon1 = float(sys.argv[3])
    lon2 = float(sys.argv[4])
    lat2 = float(sys.argv[5])
    lat1 = float(sys.argv[6])

# Since its invariant, fix or static date time
yr = '2010'
mn = '01'
dy = '01'
tm = '00:00'


# Example variables (time-invariant variables)
variables = [
    'geopotential', 'land_sea_mask', 'leaf_area_index_high_vegetation',
    'leaf_area_index_low_vegetation', 'sea_ice_cover', 'snow_depth',
    'soil_type', 'lake_cover', 'lake_depth', 'lake_ice_depth',
    ]



# Initialize the CDS API client
c = cdsapi.Client()

options = {
        'product_type': 'reanalysis',
        'variable': variables,  # List of variables to retrieve (e.g., 'orography', 'land_sea_mask')
        'year': yr,  # For time-invariant datasets, you can use any available year
        'month': mn,
        'day': dy,
        'time': tm,  # One timestamp is sufficient since the data is time-invariant
        'format': oformat,  # Choose between 'netcdf' and 'grib'
    }
ofile = f'era5_invariant_{yr}{mn}{dy}{tm.replace(':','')}_{lon1}_{lat1}-{lon2}_{lat2}.{oformat}'  # Output file
if not overglobe:
    options['area'] = [lat1, lon1, lat2, lon2],  # Define the bounding box around the location

# Download the ERA5 time-invariant dataset
c.retrieve(
    'reanalysis-era5-single-levels',  # Time-invariant variables available under single-levels dataset
    options,
    ofile  # Output file
)
print(f'Data downloaded: {ofile}')
