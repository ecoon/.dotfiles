export CODE_BASE=/Users/Shared/ornldev/code

# modulefiles
source /opt/homebrew/opt/lmod/init/zsh
module use -a ${CODE_BASE}/mpi/modulefiles
module use -a ${CODE_BASE}/seacas/modulefiles
module use -a ${CODE_BASE}/mstk/modulefiles
module use -a ${CODE_BASE}/MATK/modulefiles
module use -a ${CODE_BASE}/e3sm/modulefiles
alias moduel="module"

# ATS
export ATS_BASE=${CODE_BASE}/ats
export PYTHONPATH=${CODE_BASE}/ats/ats_manager:${PYTHONPATH}
module use -a ${ATS_BASE}/modulefiles
