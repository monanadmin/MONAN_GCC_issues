#!/bin/bash
  
# Input variables:--------------------------------------
EXP=${1};         #EXP=GFS
RES=${2};         #RES=1024002
YYYYMMDDHHi=${3}; #YYYYMMDDHHi=2024010100
YYYYMMDDHHf=${4}; #YYYYMMDDHHi=2024070100
FCST=${5};        #FCST=240
#NDAYS=${5}        #numero de dias do ciclo
#-------------------------------------------------------


# Local variables--------------------------------------
yyyymmddi=${YYYYMMDDHHi:0:8}
yyyymmddf=${YYYYMMDDHHf:0:8}
#hhi=${YYYYMMDDHHi:8:2}
#yyyymmddhhf=$(date +"%Y%m%d%H" -d "${yyyymmddi} ${hhi}:00 ${FCST} hours" )
#final_date=${yyyymmddhhf:0:4}-${yyyymmddhhf:4:2}-${yyyymmddhhf:6:2}_${yyyymmddhhf:8:2}.00.00
#-------------------------------------------------------


let NDAYS=($(date +%s -d $yyyymmddf)-$(date +%s -d $yyyymmddi))/86400
echo "initial_date=$yyyymmddi"
echo "final_date=$yyyymmddf"
echo "NDAYS=$NDAYS"
echo "running the cycle..."
echo ""


for j in $(seq 0 $NDAYS)
do
   echo "j=$j days "
   hh=${YYYYMMDDHHi:8:2}
   currentdate=`date -d "${YYYYMMDDHHi:0:8} ${hh}:00 ${j} days" +"%Y%m%d%H"`
   echo "${currentdate}"
   diag_name=MONAN_DIAG_G_MOD_GFS_${YYYYMMDDHHi}_${currentdate}.00.00.x${RES}L55.nc
   echo "diag_name=${diag_name}"
   #./2.pre_processing.bash ${EXP} ${RES} ${currentdate} ${FCST} > saida_pre.txt &
   #wait
   #./3.run_model.bash ${EXP} ${RES} ${currentdate} ${FCST} > saida_model.txt &
   #wait
   #./4.run_post.bash ${EXP} ${RES} ${currentdate} ${FCST} > saida_post.txt &
   #wait
   #rm -rf ../dataout/${currentdate}/Model
   mkdir -p /home/monan/tc/1.0.0/${currentdate}
   cp -rf /mnt/beegfs/eduardo.khamis/issues/555/scripts_CD-CT/dataout/${currentdate}/Pre /home/monan/tc/1.0.0/${currentdate}
   #cp -rf /mnt/beegfs/eduardo.khamis/issues/555/scripts_CD-CT/dataout/${currentdate}/Model /home/monan/tc/1.0.0/${currentdate}
   #mkdir -p /mnt/beegfs/monan/tc/1.0.0/${currentdate}
   #cp -rf /mnt/beegfs/eduardo.khamis/issues/555/scripts_CD-CT/dataout/${currentdate}/Post /mnt/beegfs/monan/tc/1.0.0/${currentdate}
done
