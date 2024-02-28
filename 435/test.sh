# cd /mnt/beegfs/denis.eiras/MONAN_GCC_issues/435
current_date=$(date +'%Y%m%d%H%M%S')
time python isobaric_interp.py /mnt/beegfs/monan/MONAN-scripts/egeon_oper/MONAN/testcase/runs/GFS/2024022000/monanprd/history.2024-03-01_00.00.00.nc "iso_winds_${current_date}.nc" > out_serial.txt

