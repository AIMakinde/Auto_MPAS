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
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.invariant/197901/e5.oper.invariant.128_026_cl.ll025sc.1979010100_1979010100.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.invariant/197901/e5.oper.invariant.128_027_cvl.ll025sc.1979010100_1979010100.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.invariant/197901/e5.oper.invariant.128_028_cvh.ll025sc.1979010100_1979010100.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.invariant/197901/e5.oper.invariant.128_029_tvl.ll025sc.1979010100_1979010100.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.invariant/197901/e5.oper.invariant.128_030_tvh.ll025sc.1979010100_1979010100.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.invariant/197901/e5.oper.invariant.128_043_slt.ll025sc.1979010100_1979010100.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.invariant/197901/e5.oper.invariant.128_074_sdfor.ll025sc.1979010100_1979010100.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.invariant/197901/e5.oper.invariant.128_129_z.ll025sc.1979010100_1979010100.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.invariant/197901/e5.oper.invariant.128_160_sdor.ll025sc.1979010100_1979010100.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.invariant/197901/e5.oper.invariant.128_161_isor.ll025sc.1979010100_1979010100.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.invariant/197901/e5.oper.invariant.128_162_anor.ll025sc.1979010100_1979010100.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.invariant/197901/e5.oper.invariant.128_163_slor.ll025sc.1979010100_1979010100.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.invariant/197901/e5.oper.invariant.128_172_lsm.ll025sc.1979010100_1979010100.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.invariant/197901/e5.oper.invariant.228_007_dl.ll025sc.1979010100_1979010100.grb
