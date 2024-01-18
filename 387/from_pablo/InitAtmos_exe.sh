#!/bin/bash
#SBATCH --job-name=ic_mpas
#SBATCH --nodes=1                         # depends on how many boundary files are available
#SBATCH --partition=batch
#SBATCH --tasks-per-node=32               # only for benchmark
####SBATCH --ntasks=2048
#SBATCH --time=01:00:00
#SBATCH --output=/mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/logs/my_job_ic.o%j    # File name for standard output
#SBATCH --error=/mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/logs/my_job_ic.e%j     # File name for standard error output
#
export OMP_NUM_THREADS=1
ulimit -c unlimited
#ulimit -m unlimited
ulimit -v unlimited
ulimit -s unlimited

#export OMPI_MCA_btl_openib_allow_ib=1
#export OMPI_MCA_btl_openib_if_include="mlx5_0:1"
export PMIX_MCA_gds=hash

. /home/julio.fernandez/.spack/gnu/env.sh

# Load packges for MPAS@GNU:
spack load --only dependencies mpas-model%gcc@9.4.0
spack load --list

cd /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100

echo  "STARTING AT `date` "
Start=`date +%s.%N`
echo $Start >  /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/Timing.InitAtmos

mpirun -np $SLURM_NTASKS ./init_atmosphere_model

# Wait for all jobs to finish before exiting the job submission script

#wait

End=`date +%s.%N`
echo  "FINISHED AT `date` "
echo $End   >> /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/Timing.InitAtmos
echo $Start $End | awk '{print $2 - $1" sec"}' >>  /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/Timing.InitAtmos

 mv Timing.InitAtmos log.*.out /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/logs
 mv namelist.init* streams.init* /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/scripts
 mv InitAtmos_exe.sh /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/scripts

# find /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100 -maxdepth 1 -type l -exec rm -f {} \;

date
exit 0
