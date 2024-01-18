#!/bin/bash
#SBATCH --job-name=gfs4mpas
#SBATCH --nodes=1
#SBATCH --partition=batch
#SBATCH --tasks-per-node=1                      # ic for benchmark
####SBATCH --ntasks=2048
#SBATCH --time=00:30:00
#SBATCH --output=/mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/logs/my_job_ungrib.o%j    # File name for standard output
#SBATCH --error=/mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/logs/my_job_ungrib.e%j     # File name for standard error output
#
ulimit -s unlimited
ulimit -c unlimited
#ulimit -m unlimited
ulimit -v unlimited

#export  PMI_NO_FORK=1

#export OMPI_MCA_btl_openib_allow_ib=1
#export OMPI_MCA_btl_openib_if_include="mlx5_0:1"
export PMIX_MCA_gds=hash

echo  "STARTING AT `date` "
Start=`date +%s.%N`
echo $Start > Timing.degrib
#
#module list
#ldd ungrib.exe

. /home/julio.fernandez/.spack/gnu/env.sh
# cp /usr/lib64/libjasper.so* /home/julio.fernandez/local/lib64
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/home/julio.fernandez/local/lib64

# Load packges for MPAS@GNU:
spack load --only dependencies mpas-model%gcc@9.4.0
spack load --list

ldd ungrib.exe

cd /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/wpsprd

if [ -e namelist.wps ]; then rm -f namelist.wps; fi
#
# Now surface and upper air atmospheric variables
#
rm -f GRIBFILE.* namelist.wps

sed -e "s,#LABELI#,2021-06-01_00:00:00,g;s,#PREFIX#,GFS2,g" 	/mnt/beegfs/julio.fernandez/MPAS/testcase/namelist/namelist.wps.TEMPLATE > ./namelist.wps

./link_grib.csh gfs.t00z.pgrb2.0p25.f000.*.grib2

mpirun -np 1 ./ungrib.exe
#mv ungrib.log ungrib.2021-06-01_00:00:00.log

echo 2021-06-01_00

#ln -sf FILE\:2021-06-01_00 FILE3\:2021-06-01_00

rm -f GRIBFILE.*

End=`date +%s.%N`
echo  "FINISHED AT `date` "
echo $End   >>Timing.degrib
echo $Start $End | awk '{print $2 - $1" sec"}' >> Timing.degrib

#grep "Successful completion of ungrib." ungrib.log >& /dev/null
grep "Successful completion of program ungrib.exe" ungrib.log >& /dev/null

if [ $? -ne 0 ]; then
   echo "  BUMMER: Ungrib generation failed for some yet unknown reason."
   echo " "
   tail -10 /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/logs/ungrib.log
   echo " "
   exit 21
fi
   echo "  ####################################"
   echo "  ### Ungrib completed - $(date) ####"
   echo "  ####################################"
   echo " " 
#
# clean up and remove links
#
   mv ungrib.*.log /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/logs
   mv ungrib.log /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/logs/ungrib.2021-06-01_00:00:00.log
   mv Timing.degrib /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/logs
   mv namelist.wps degrib_exe.sh /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/scripts
   rm -f link_grib.csh
   cd ..
   ln -sf wpsprd/GFS2\:2021-06-01_00 .
   find /mnt/beegfs/julio.fernandez/MPAS/testcase/runs/GFS2/2021060100/wpsprd -maxdepth 1 -type l -exec rm -f {} \;

echo "End of degrib Job"

exit 0
