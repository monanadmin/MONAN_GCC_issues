#!/bin/bash
#SBATCH --job-name=ISO
#SBATCH --nodes=1
#SBATCH --partition=batch
#SBATCH --tasks-per-node=1                      # ic for benchmark
#SBATCH --time=02:00:00
#SBATCH --output=./sbatch.o%j    # File name for standard output
#SBATCH --error=./sbatch.e%j     # File name for standard error output
#
ulimit -s unlimited
ulimit -c unlimited
ulimit -v unlimited

export PMIX_MCA_gds=hash
export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH:${HOME}/local/lib64

cd $PWD

module load python-3.9.15-gcc-9.4.0-f466wuv
source .venv/bin/activate

./test.sh

