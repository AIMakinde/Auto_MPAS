#! /bin/csh -f
#
# c-shell script to download selected files from rda.ucar.edu using Wget
# NOTE: if you want to run under a different shell, make sure you change
#       the 'set' commands according to your shell's syntax
# after you save the file, don't forget to make it executable
#   i.e. - "chmod 755 <name_of_script>"
#
# Experienced Wget Users: add additional command-line flags here
#   Use the -r (--recursive) option with care
set opts = "-N"
#
set cert_opt = ""
# If you get a certificate verification error (version 1.10 or higher),
# uncomment the following line:
#set cert_opt = "--no-check-certificate"
#
# download the file(s)
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.sfc/202204/e5.oper.an.sfc.128_031_ci.ll025sc.2022040100_2022043023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.sfc/202204/e5.oper.an.sfc.128_034_sstk.ll025sc.2022040100_2022043023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.sfc/202204/e5.oper.an.sfc.128_035_istl1.ll025sc.2022040100_2022043023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.sfc/202204/e5.oper.an.sfc.128_036_istl2.ll025sc.2022040100_2022043023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.sfc/202204/e5.oper.an.sfc.128_037_istl3.ll025sc.2022040100_2022043023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.sfc/202204/e5.oper.an.sfc.128_038_istl4.ll025sc.2022040100_2022043023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.sfc/202204/e5.oper.an.sfc.128_039_swvl1.ll025sc.2022040100_2022043023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.sfc/202204/e5.oper.an.sfc.128_040_swvl2.ll025sc.2022040100_2022043023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.sfc/202204/e5.oper.an.sfc.128_041_swvl3.ll025sc.2022040100_2022043023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.sfc/202204/e5.oper.an.sfc.128_042_swvl4.ll025sc.2022040100_2022043023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.sfc/202204/e5.oper.an.sfc.128_134_sp.ll025sc.2022040100_2022043023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.sfc/202204/e5.oper.an.sfc.128_139_stl1.ll025sc.2022040100_2022043023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.sfc/202204/e5.oper.an.sfc.128_141_sd.ll025sc.2022040100_2022043023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.sfc/202204/e5.oper.an.sfc.128_151_msl.ll025sc.2022040100_2022043023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.sfc/202204/e5.oper.an.sfc.128_159_blh.ll025sc.2022040100_2022043023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.sfc/202204/e5.oper.an.sfc.128_165_10u.ll025sc.2022040100_2022043023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.sfc/202204/e5.oper.an.sfc.128_166_10v.ll025sc.2022040100_2022043023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.sfc/202204/e5.oper.an.sfc.128_167_2t.ll025sc.2022040100_2022043023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.sfc/202204/e5.oper.an.sfc.128_168_2d.ll025sc.2022040100_2022043023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.sfc/202204/e5.oper.an.sfc.128_170_stl2.ll025sc.2022040100_2022043023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.sfc/202204/e5.oper.an.sfc.228_247_100v.ll025sc.2022040100_2022043023.grb
