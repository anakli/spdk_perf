#!/bin/bash

# Script to run perf tests
#
# Ana Klimovic
# June 2016

# Parameters:
# 	$1 = output filename


if [ $# -ne 1 ]
  then
    echo "Usage: ./run_perf_rops.sh [output_filename]"
fi

# Create output file and set permissions for root to write
touch $1
chmod o+w $1

printf "Workload; Read Ratio; Num cores; Max Qdepth; Lambda; Rd IOPS; Wr IOPS; Rd Avg; Rd p95; Rd p99; Wr Avg; Wr p95; Wr p99; ; #dropped \n" >> $1

for m in  100 # 95 90 85 80 75 70 60 50 40 30 20 10 0 
do
	for lambda in 1000 5000 10000 15000 20000 30000 40000 50000 75000 100000 125000 150000 175000 200000 250000 300000 350000 400000 
	do
		#printf "randrw-openloop-exp; %d; 1; 1024; %d;" "$m" "$lambda" >> $1
		#sudo ./perf -t 120 -s 4096 -q 1024 -w randrw -M $m -c 1 -o $1 -L $lambda	
		printf "randrw-openloop-fixed; %d; 1; 1024; %d;" "$m" "$lambda" >> $1
		sudo ./perf -t 120 -s 4096 -q 1024 -w randrw -M $m -c 1 -o $1 -L $lambda -d fixed
	done
	printf "\n" >> $1
done
