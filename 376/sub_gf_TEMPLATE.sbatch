#!/bin/bash
#SBATCH --job-name=GF_<RUNTYPE>
#SBATCH --nodes=1
#SBATCH --partition=batch
#SBATCH --tasks-per-node=1
#SBATCH --ntasks=1
#SBATCH --time=04:00:00
#sbatch --mem-per-cpu=64000M
#SBATCH --output=/mnt/beegfs/luiz.rodrigues/bin/GF-<RUNTYPE><NNXPxNNYP>.txt
#SBATCH --exclusive

cd $SLURM_SUBMIT_DIR
echo $SLURM_SUBMIT_DIR
module swap gnu9 intel
module swap openmpi4 impi/2021.4.0
module load phdf5
module load netcdf
module load netcdf-fortran
module load hwloc
echo "Lista de módulos carregados: "
module list
echo "============================="

export TMPDIR=/mnt/beegfs/luiz.rodrigues/bin/tmp

ulimit -s unlimited
MPI_PARAMS="-iface ib0 -bind-to core -map-by core"
export OMP_NUM_THREADS=1
export MKL_NUM_THREADS=1
export I_MPI_DEBUG=5
export MKL_DEBUG_CPU_TYPE=5
export I_MPI_ADJUST_BCAST=12 ## NUMA aware SHM-Based (AVX512)
mpirun -env MKL_DEBUG_CPU_TYPE=5 -env UCX_NET_DEVICES=mlx5_0:1 -genvall /mnt/beegfs/eduardo.khamis/376/brams/build/brams-6.0 -f /mnt/beegfs/luiz.rodrigues/bin/RAMSIN_BASIC_GF_10KM__<NNXPxNNYP>_<RUNTYPE> >& GF-<RUNTYPE><NNXPxNNYP>.out

