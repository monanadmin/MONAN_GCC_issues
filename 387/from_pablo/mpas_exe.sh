#!/bin/bash
#SBATCH --nodes=8
#SBATCH --ntasks=1024
#SBATCH --tasks-per-node=128
#SBATCH --partition=batch  # PESQ1
#SBATCH --job-name=20210601
#SBATCH --time=8:00:00    # 12:00:00         
#SBATCH --output=/mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/logs/my_job_mpas.o%j   # File name for standard output
#SBATCH --error=/mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/logs/my_job_mpas.e%j    # File name for standard error output

export executable=atmosphere_model
#export OMPI_MCA_btl_openib_allow_ib=1
#export OMPI_MCA_btl_openib_if_include="mlx5_0:1"
export PMIX_MCA_gds=hash

# Carregar o ambiente do spack:
. /home/julio.fernandez/.spack/gnu/env.sh

# Load packges for MPAS@GNU:
spack load --only dependencies mpas-model%gcc@9.4.0
spack load --list

ulimit -s unlimited

cd /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100

#export MPAS_DYNAMICS_RANKS_PER_NODE=2
#export MPAS_RADIATION_RANKS_PER_NODE=6
#export MALLOCSTATS=1

#export OMP_NUM_THREADS=1
#export I_MPI_OFI_PROVIDER=Verbs

#cd  
echo $SLURM_JOB_NUM_NODES

echo  "STARTING AT `date` "
Start=`date +%s.%N`
echo $Start >  /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/Timing

#time mpirun -np $SLURM_NTASKS  -genv UCX_TLS=all ./${executable}
time mpirun -np $SLURM_NTASKS ./${executable}

End=`date +%s.%N`
echo  "FINISHED AT `date` "
echo $End   >> /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/Timing
echo $Start $End | awk '{print $2 - $1" sec"}' >>  /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/Timing

#
# move dataout, clean up and remove files/links
#
#mv slurm-${SLURM_JOBID}.out /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/logs
mv log.atmosphere.*.out /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/logs

mv namelist.atmosphere /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/scripts
mv mpas_exe.sh /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/scripts
mv stream* /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/scripts
mv x1.*.init.nc* /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/mpasprd
mv diag* /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/mpasprd
mv histor* /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/mpasprd
mv Timing /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/logs/Timing.MPAS

#find /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100 -maxdepth 1 -type f -exec rm -f {} \;
find /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100 -maxdepth 1 -type l -exec rm -f {} \;

exit 0
