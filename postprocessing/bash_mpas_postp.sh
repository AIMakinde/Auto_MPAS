
conda activate cdoenv

{
#./mpas_ppc_var_Aug1.sh
#./mpas_ppc_prc_Aug1.sh

#./mpas_ppc_var_Aug2.sh
#./mpas_ppc_prc_Aug2.sh

#./mpas_ppc_var_Aug3.sh
#./mpas_ppc_prc_Aug3.sh

#./mpas_ppc_var_Aug4.sh
#./mpas_ppc_prc_Aug4.sh

./mpas_ppc_var_Aug5.sh
./mpas_ppc_prc_Aug5.sh

#./mpas_ppc_var_Aug6.sh
#./mpas_ppc_prc_Aug6.sh

#./mpas_ppc_var_Aug7.sh
#./mpas_ppc_prc_Aug7.sh

#./mpas_ppc_var_Aug8.sh
#./mpas_ppc_prc_Aug8.sh

} 2>&1 | tee -a run.log
