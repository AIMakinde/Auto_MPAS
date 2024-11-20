# Auto_MPAS

**Auto_MPAS** is a collection of automation scripts designed to streamline the setup, configuration, and management of the MPAS-Atmosphere model, with potential expansion to MPAS-Ocean in the future. While it doesn't directly perform MPAS tasks, it simplifies the intricate steps required to run MPAS efficiently, especially on high-performance computing systems. This documentation will guide you through the repository structure, usage, and customization.

---

## Table of Contents

1. [Introduction](#introduction)  
2. [Features](#features)  
3. [Repository Structure](#repository-structure)  
4. [Installation](#installation)  
5. [Usage](#usage)  
6. [Postprocessing](#postprocessing)  
7. [Contributing](#contributing)  
8. [License](#license)  

---

## Introduction

`Auto_MPAS` simplifies the tedious processes involved in setting up and running MPAS-Atmosphere simulations. It automates dataset downloads, preprocessing, initialization, and model integration, ensuring smooth execution even for long-term simulations on high-performance computing systems.

---

## Features

- **Automated Downloads**: Retrieve datasets (e.g., CFSR, ERA5) with minimal effort.  
- **File Organization**: Automatically handle file linking and copying for MPAS processes (including _init_atmosphere_ and _atmosphere_).  
- **Initialization Automation**: Configure and run the `init_atmosphere` process, including repetitive runs for static, surface and meteorology interpolation.  
- **Simulation Management**: Monitor and restart simulations when wall time limits are reached (e.g on CHPC - Center for High Performance Computing).  
- **Postprocessing**: Convert MPAS outputs, including 3D fields, to netCDF format on a regular Latlon grid for analysis (requires manual invocation).  

---

## Repository Structure
The following is a breakdown of the directory and file structure within the repository:

```
Auto_MPAS/
├── scripts/
│	│### Key Bash Scripts
│	├── `bash_auto_run.cfsr.sh`				# Automates simulation setup and execution using CFSR data.
│	├── `bash_auto_run.era5.sh`				# Automates simulation setup and execution using ERA5 data.
│	├── `setup_mpas*_workdir.sh`			# Sets up MPAS directories for specific resolutions (e.g., 60 km).
│	├── `bash_dwn_cfsr.sh`					# Automates downloads of CFSR data.
│	├── `bash_dwn_era5.sh`					# Automates downloads of ERA5 data.
│	├── `bash_ung_cfsr.sh`					# Automates the ungrib of CFSR forcing data.
│	├── `bash_ung_era5.sh`					# Automates the ungrib of ERA5 forcing data.
│	├── `restart_script.sh`					# Handles automatic restarts when simulations hit wall time.
│	│
│	│### Key Python Scripts
│	├── `cfsr_dwn_*.py`						# Python scripts for downloading CFSR data at different levels in grib formats.
│	├── `era5_dwn_*.py`						# Python scripts for downloading ERA5 data at different levels in grib formats.
│	├── `mpas_isobaric_interp.py`			# Interpolates MPAS output to fixed pressure levels.
│	│
│	│### Configurations
│	├── `namelist.init_atmosphere`			# Template namelist for initializing MPAS atmospheric conditions.
│	├── `streams.init_atmosphere`			# Template stream configuration for initialization.
│	├── `namelist.atmosphere`				# Template namelist for MPAS-Atmosphere simulation.
│	└── `streams.atmosphere`				# Template stream configuration for simulations.
├── postprocessing/
│   ├── cdo_mpas_postp_variables.sh			# Extract and process variables from Latlon files with temporal resolutions (e.g., hourly, daily, monthly).
│   ├── cdo_mpas_postp_precipitation.sh		# Specifically handles precipitation data.
│   └── cdo_mpas_postp_geop.sh				# Computes geopotential height based on geometric height fields from MPAS data.
├── plotscripts/
│   ├── ncl_scripts							# Collection of third-party NCL Scripts for plotting field on native MPAS Grids
│	└── python_scripts						# Collection of third-part Python scripts for plotting fields on native MPAS Grids
├── docs/
    └── README.md                			# Repository documentation
   
```

---

## Installation

1. **Clone the Repository**:  
   ```bash
   git clone https://github.com/AIMakinde/Auto_MPAS.git
   cd auto_mpas
   ```

2. **Dependencies**:  
   - **Bash**: Ensure a Bash-compatible shell is installed.  
   - **Python**: Install Python 3.x and required packages:
	  - `netCDF4`
	  - `numpy`
	  - `json`
	  - `multiprocessing`
	  - `requests`
	  - `cdsapi`
   - **CDO**: Install the Climate Data Operators (CDO) for postprocessing.

---

## Configuration
	### `bash_auto_run.*.sh`
	This script serves as the main entry point for automating MPAS simulations. The user needs to modify certain sections to match their simulation requirements.

	#### Key Sections to Edit

	```bash
	#!/bin/bash

	# ==== Forcing dataset section ===============

	dtpath="data/cfsr"                        ## where do you want all dataset to be downloaded to?
	prsdwnstartdatetime=202204070000          ## start datetime for downloading pressure level forcing data
	prsdwnenddatetime=202204150000            ## Note: at least more than 6 days ahead of prsdwnstartdatetime, to avoid ungrib error
	sfcdwnstartdatetime=202204070000          ## Start datetime for downloading surface forcing dataset
	sfcdwnenddatetime=202204150000            ## End datetime for downloading surface forcing dataset
	singlemultiyears=1                        ## Option 0 - download forcing data year by year (short simulation).
											  ## Option 1 - download forcing data all at once (long simulation).

	# ===== Ungrib section ========================

	prsungrbstartdatetime=2022-04-07_00:00:00 ## Make sure this matches 'prsdwnstartdatetime' (use '_' and ':' as separators).
	prsungrbenddatetime=2022-04-12_06:00:00   ## Should be at most 18 hrs less than 'prsdwnenddatetime'.
	sfcungrbstartdatetime=2022-04-07_00:00:00 ## Should be <= 'prsungrbstartdatetime'.
	sfcungrbenddatetime=2022-04-15_00:00:00   ## Should be <= 'sfcdwnenddatetime'.
	manyyearsungrib=1                         ## Option 0 - ungrib year by year; 1 - ungrib all at once.

	# ========= Simulation settings section ========
	simstartdate=2022-04-07_00:00:00          ## Matches 'prsungrbstartdatetime'.
	simenddate=2022-04-15_00:00:00            ## Define simulation end datetime.

	rundir="60km_uniform"                     ## Model directory name for storing executables and outputs.
	rsltn="60km"                              ## Resolution (e.g., "60km").
	lowRsltn=60                               ## For uniform resolutions, set to same as 'rsltn'.
	meshdir="meshes/60km"                     ## Location of the mesh for the chosen resolution.
	ncores=192                                ## Number of processors to use. Ensure partitioning file exists in 'meshdir'.
	LOGFILE="log.auto_60km"                   ## Log file name.

	# ======== Simulation Switches =============
	# Option 0 - Do not skip (run the process).
	# Option 1 - Skip the process.

	skipdwn=1
	skipung=1
	skipinit=0
	skipatmos=0

	# ======== Dataset Options =============
	# Option 0 - Use CFSR forcing data.
	# Option 1 - Use ERA5 forcing data.

	datasrc=0
	```

---

## Usage
To get started:
1. Clone this repository and ensure dependencies are installed.
2. Edit the `bash_auto_run.*.sh` script to configure your simulation.
3. Run the desired Bash script (e.g., `bash_auto_run.cfsr.sh`) to automate the process.

---

## Contributing

Contributions are welcome! If you'd like to improve the scripts or add new features:  
1. Fork the repository.  
2. Create a feature branch.  
3. Submit a pull request.

---

## License

This repository is licensed under [MIT License](LICENSE).