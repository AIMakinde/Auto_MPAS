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
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_060_pv.ll025sc.2022040500_2022040523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_075_crwc.ll025sc.2022040500_2022040523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_076_cswc.ll025sc.2022040500_2022040523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_129_z.ll025sc.2022040500_2022040523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_130_t.ll025sc.2022040500_2022040523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_131_u.ll025uv.2022040500_2022040523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_132_v.ll025uv.2022040500_2022040523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_133_q.ll025sc.2022040500_2022040523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_135_w.ll025sc.2022040500_2022040523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_138_vo.ll025sc.2022040500_2022040523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_155_d.ll025sc.2022040500_2022040523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_157_r.ll025sc.2022040500_2022040523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_203_o3.ll025sc.2022040500_2022040523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_246_clwc.ll025sc.2022040500_2022040523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_247_ciwc.ll025sc.2022040500_2022040523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_248_cc.ll025sc.2022040500_2022040523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_060_pv.ll025sc.2022040600_2022040623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_075_crwc.ll025sc.2022040600_2022040623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_076_cswc.ll025sc.2022040600_2022040623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_129_z.ll025sc.2022040600_2022040623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_130_t.ll025sc.2022040600_2022040623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_131_u.ll025uv.2022040600_2022040623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_132_v.ll025uv.2022040600_2022040623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_133_q.ll025sc.2022040600_2022040623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_135_w.ll025sc.2022040600_2022040623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_138_vo.ll025sc.2022040600_2022040623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_155_d.ll025sc.2022040600_2022040623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_157_r.ll025sc.2022040600_2022040623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_203_o3.ll025sc.2022040600_2022040623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_246_clwc.ll025sc.2022040600_2022040623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_247_ciwc.ll025sc.2022040600_2022040623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_248_cc.ll025sc.2022040600_2022040623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_060_pv.ll025sc.2022040700_2022040723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_075_crwc.ll025sc.2022040700_2022040723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_076_cswc.ll025sc.2022040700_2022040723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_129_z.ll025sc.2022040700_2022040723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_130_t.ll025sc.2022040700_2022040723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_131_u.ll025uv.2022040700_2022040723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_132_v.ll025uv.2022040700_2022040723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_133_q.ll025sc.2022040700_2022040723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_135_w.ll025sc.2022040700_2022040723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_138_vo.ll025sc.2022040700_2022040723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_155_d.ll025sc.2022040700_2022040723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_157_r.ll025sc.2022040700_2022040723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_203_o3.ll025sc.2022040700_2022040723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_246_clwc.ll025sc.2022040700_2022040723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_247_ciwc.ll025sc.2022040700_2022040723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_248_cc.ll025sc.2022040700_2022040723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_060_pv.ll025sc.2022040800_2022040823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_075_crwc.ll025sc.2022040800_2022040823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_076_cswc.ll025sc.2022040800_2022040823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_129_z.ll025sc.2022040800_2022040823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_130_t.ll025sc.2022040800_2022040823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_131_u.ll025uv.2022040800_2022040823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_132_v.ll025uv.2022040800_2022040823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_133_q.ll025sc.2022040800_2022040823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_135_w.ll025sc.2022040800_2022040823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_138_vo.ll025sc.2022040800_2022040823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_155_d.ll025sc.2022040800_2022040823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_157_r.ll025sc.2022040800_2022040823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_203_o3.ll025sc.2022040800_2022040823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_246_clwc.ll025sc.2022040800_2022040823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_247_ciwc.ll025sc.2022040800_2022040823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_248_cc.ll025sc.2022040800_2022040823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_060_pv.ll025sc.2022040900_2022040923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_075_crwc.ll025sc.2022040900_2022040923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_076_cswc.ll025sc.2022040900_2022040923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_129_z.ll025sc.2022040900_2022040923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_130_t.ll025sc.2022040900_2022040923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_131_u.ll025uv.2022040900_2022040923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_132_v.ll025uv.2022040900_2022040923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_133_q.ll025sc.2022040900_2022040923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_135_w.ll025sc.2022040900_2022040923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_138_vo.ll025sc.2022040900_2022040923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_155_d.ll025sc.2022040900_2022040923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_157_r.ll025sc.2022040900_2022040923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_203_o3.ll025sc.2022040900_2022040923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_246_clwc.ll025sc.2022040900_2022040923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_247_ciwc.ll025sc.2022040900_2022040923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_248_cc.ll025sc.2022040900_2022040923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_060_pv.ll025sc.2022041000_2022041023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_075_crwc.ll025sc.2022041000_2022041023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_076_cswc.ll025sc.2022041000_2022041023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_129_z.ll025sc.2022041000_2022041023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_130_t.ll025sc.2022041000_2022041023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_131_u.ll025uv.2022041000_2022041023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_132_v.ll025uv.2022041000_2022041023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_133_q.ll025sc.2022041000_2022041023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_135_w.ll025sc.2022041000_2022041023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_138_vo.ll025sc.2022041000_2022041023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_155_d.ll025sc.2022041000_2022041023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_157_r.ll025sc.2022041000_2022041023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_203_o3.ll025sc.2022041000_2022041023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_246_clwc.ll025sc.2022041000_2022041023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_247_ciwc.ll025sc.2022041000_2022041023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_248_cc.ll025sc.2022041000_2022041023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_060_pv.ll025sc.2022041100_2022041123.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_075_crwc.ll025sc.2022041100_2022041123.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_076_cswc.ll025sc.2022041100_2022041123.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_129_z.ll025sc.2022041100_2022041123.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_130_t.ll025sc.2022041100_2022041123.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_131_u.ll025uv.2022041100_2022041123.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_132_v.ll025uv.2022041100_2022041123.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_133_q.ll025sc.2022041100_2022041123.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_135_w.ll025sc.2022041100_2022041123.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_138_vo.ll025sc.2022041100_2022041123.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_155_d.ll025sc.2022041100_2022041123.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_157_r.ll025sc.2022041100_2022041123.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_203_o3.ll025sc.2022041100_2022041123.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_246_clwc.ll025sc.2022041100_2022041123.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_247_ciwc.ll025sc.2022041100_2022041123.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_248_cc.ll025sc.2022041100_2022041123.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_060_pv.ll025sc.2022041200_2022041223.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_075_crwc.ll025sc.2022041200_2022041223.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_076_cswc.ll025sc.2022041200_2022041223.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_129_z.ll025sc.2022041200_2022041223.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_130_t.ll025sc.2022041200_2022041223.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_131_u.ll025uv.2022041200_2022041223.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_132_v.ll025uv.2022041200_2022041223.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_133_q.ll025sc.2022041200_2022041223.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_135_w.ll025sc.2022041200_2022041223.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_138_vo.ll025sc.2022041200_2022041223.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_155_d.ll025sc.2022041200_2022041223.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_157_r.ll025sc.2022041200_2022041223.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_203_o3.ll025sc.2022041200_2022041223.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_246_clwc.ll025sc.2022041200_2022041223.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_247_ciwc.ll025sc.2022041200_2022041223.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_248_cc.ll025sc.2022041200_2022041223.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_060_pv.ll025sc.2022041300_2022041323.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_075_crwc.ll025sc.2022041300_2022041323.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_076_cswc.ll025sc.2022041300_2022041323.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_129_z.ll025sc.2022041300_2022041323.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_130_t.ll025sc.2022041300_2022041323.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_131_u.ll025uv.2022041300_2022041323.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_132_v.ll025uv.2022041300_2022041323.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_133_q.ll025sc.2022041300_2022041323.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_135_w.ll025sc.2022041300_2022041323.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_138_vo.ll025sc.2022041300_2022041323.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_155_d.ll025sc.2022041300_2022041323.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_157_r.ll025sc.2022041300_2022041323.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_203_o3.ll025sc.2022041300_2022041323.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_246_clwc.ll025sc.2022041300_2022041323.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_247_ciwc.ll025sc.2022041300_2022041323.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_248_cc.ll025sc.2022041300_2022041323.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_060_pv.ll025sc.2022041400_2022041423.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_075_crwc.ll025sc.2022041400_2022041423.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_076_cswc.ll025sc.2022041400_2022041423.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_129_z.ll025sc.2022041400_2022041423.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_130_t.ll025sc.2022041400_2022041423.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_131_u.ll025uv.2022041400_2022041423.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_132_v.ll025uv.2022041400_2022041423.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_133_q.ll025sc.2022041400_2022041423.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_135_w.ll025sc.2022041400_2022041423.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_138_vo.ll025sc.2022041400_2022041423.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_155_d.ll025sc.2022041400_2022041423.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_157_r.ll025sc.2022041400_2022041423.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_203_o3.ll025sc.2022041400_2022041423.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_246_clwc.ll025sc.2022041400_2022041423.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_247_ciwc.ll025sc.2022041400_2022041423.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_248_cc.ll025sc.2022041400_2022041423.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_060_pv.ll025sc.2022041500_2022041523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_075_crwc.ll025sc.2022041500_2022041523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_076_cswc.ll025sc.2022041500_2022041523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_129_z.ll025sc.2022041500_2022041523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_130_t.ll025sc.2022041500_2022041523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_131_u.ll025uv.2022041500_2022041523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_132_v.ll025uv.2022041500_2022041523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_133_q.ll025sc.2022041500_2022041523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_135_w.ll025sc.2022041500_2022041523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_138_vo.ll025sc.2022041500_2022041523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_155_d.ll025sc.2022041500_2022041523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_157_r.ll025sc.2022041500_2022041523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_203_o3.ll025sc.2022041500_2022041523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_246_clwc.ll025sc.2022041500_2022041523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_247_ciwc.ll025sc.2022041500_2022041523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_248_cc.ll025sc.2022041500_2022041523.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_060_pv.ll025sc.2022041600_2022041623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_075_crwc.ll025sc.2022041600_2022041623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_076_cswc.ll025sc.2022041600_2022041623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_129_z.ll025sc.2022041600_2022041623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_130_t.ll025sc.2022041600_2022041623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_131_u.ll025uv.2022041600_2022041623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_132_v.ll025uv.2022041600_2022041623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_133_q.ll025sc.2022041600_2022041623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_135_w.ll025sc.2022041600_2022041623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_138_vo.ll025sc.2022041600_2022041623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_155_d.ll025sc.2022041600_2022041623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_157_r.ll025sc.2022041600_2022041623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_203_o3.ll025sc.2022041600_2022041623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_246_clwc.ll025sc.2022041600_2022041623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_247_ciwc.ll025sc.2022041600_2022041623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_248_cc.ll025sc.2022041600_2022041623.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_060_pv.ll025sc.2022041700_2022041723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_075_crwc.ll025sc.2022041700_2022041723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_076_cswc.ll025sc.2022041700_2022041723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_129_z.ll025sc.2022041700_2022041723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_130_t.ll025sc.2022041700_2022041723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_131_u.ll025uv.2022041700_2022041723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_132_v.ll025uv.2022041700_2022041723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_133_q.ll025sc.2022041700_2022041723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_135_w.ll025sc.2022041700_2022041723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_138_vo.ll025sc.2022041700_2022041723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_155_d.ll025sc.2022041700_2022041723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_157_r.ll025sc.2022041700_2022041723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_203_o3.ll025sc.2022041700_2022041723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_246_clwc.ll025sc.2022041700_2022041723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_247_ciwc.ll025sc.2022041700_2022041723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_248_cc.ll025sc.2022041700_2022041723.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_060_pv.ll025sc.2022041800_2022041823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_075_crwc.ll025sc.2022041800_2022041823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_076_cswc.ll025sc.2022041800_2022041823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_129_z.ll025sc.2022041800_2022041823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_130_t.ll025sc.2022041800_2022041823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_131_u.ll025uv.2022041800_2022041823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_132_v.ll025uv.2022041800_2022041823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_133_q.ll025sc.2022041800_2022041823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_135_w.ll025sc.2022041800_2022041823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_138_vo.ll025sc.2022041800_2022041823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_155_d.ll025sc.2022041800_2022041823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_157_r.ll025sc.2022041800_2022041823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_203_o3.ll025sc.2022041800_2022041823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_246_clwc.ll025sc.2022041800_2022041823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_247_ciwc.ll025sc.2022041800_2022041823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_248_cc.ll025sc.2022041800_2022041823.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_060_pv.ll025sc.2022041900_2022041923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_075_crwc.ll025sc.2022041900_2022041923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_076_cswc.ll025sc.2022041900_2022041923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_129_z.ll025sc.2022041900_2022041923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_130_t.ll025sc.2022041900_2022041923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_131_u.ll025uv.2022041900_2022041923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_132_v.ll025uv.2022041900_2022041923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_133_q.ll025sc.2022041900_2022041923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_135_w.ll025sc.2022041900_2022041923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_138_vo.ll025sc.2022041900_2022041923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_155_d.ll025sc.2022041900_2022041923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_157_r.ll025sc.2022041900_2022041923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_203_o3.ll025sc.2022041900_2022041923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_246_clwc.ll025sc.2022041900_2022041923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_247_ciwc.ll025sc.2022041900_2022041923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_248_cc.ll025sc.2022041900_2022041923.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_060_pv.ll025sc.2022042000_2022042023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_075_crwc.ll025sc.2022042000_2022042023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_076_cswc.ll025sc.2022042000_2022042023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_129_z.ll025sc.2022042000_2022042023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_130_t.ll025sc.2022042000_2022042023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_131_u.ll025uv.2022042000_2022042023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_132_v.ll025uv.2022042000_2022042023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_133_q.ll025sc.2022042000_2022042023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_135_w.ll025sc.2022042000_2022042023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_138_vo.ll025sc.2022042000_2022042023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_155_d.ll025sc.2022042000_2022042023.grb
wget $cert_opt $opts https://data.rda.ucar.edu/ds633.0/e5.oper.an.pl/202204/e5.oper.an.pl.128_248_cc.ll025sc.2022042000_2022042023.grb
