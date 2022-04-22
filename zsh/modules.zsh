export CODE_BASE=/Users/Shared/ornldev/code

# modulefiles
source /usr/local/opt/lmod/init/zsh
module use -a ${CODE_BASE}/mpi/modulefiles
module use -a ${CODE_BASE}/seacas/modulefiles
module use -a ${CODE_BASE}/mstk/modulefiles
module use -a ${CODE_BASE}/MATK/modulefiles
alias moduel="module"

# ATS
export ATS_BASE=${CODE_BASE}/ats
export PYTHONPATH=${ATS_BASE}/ats_manager:${PYTHONPATH}
module use -a ${ATS_BASE}/modulefiles
