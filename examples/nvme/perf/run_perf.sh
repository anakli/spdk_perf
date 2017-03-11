#!/bin/bash

# Script to run perf tests
# June 2016

# Parameters:
# 	$1 = output_filename


if [ $# -ne 1 ]
  then
    echo "Usage: ./run_perf.sh [output_filename]"
fi

# Create output file and set permissions for root to write
touch $1
chmod o+w $1

printf "Workload; Read Ratio; Num cores; Max Qdepth; Req Size; Target IOPS; Rd IOPS; Wr IOPS; Rd Avg; Rd p95; Rd p99; Wr Avg; Wr p95; Wr p99; ; #dropped \n" >> $1


# sweep request sizes
for s in 4096 # 1024 8192 16384 32768 65536
do	
	# sweep read/write ratios
	for m in  100 # 99 95 90 85 80 75 70 60 50 40 30 20 10 0 
	do
		# sweep target IOPS
		# note lambda is the target IOPS *per core*
		# total target IOPS is lambda times the num cores, specified via coremask parameter
		for lambda in 1000 10000 25000 50000 100000 125000 150000 175000 200000 250000 300000 350000 400000 4500000 500000 600000 700000 800000 900000 1000000
		do
			printf "randrw-openloop-exp; %d; 1; 1024; %d; %d;" "$m"  "$s" "$lambda" >> $1
			#sudo ./perf -t 120 -s 4096 -q 1024 -w randrw -M $m -c 1 -o $1 -L $lambda 
			# note: -c is the coremask in hex
		    #       -c 1 means use a single core 
		    # 	    -c 3 means use 2 cores
		    #       -c f means use 4 cores	
			#		keep in mind, to achieve high IOPS, may need more than 1 core
			sudo ./perf -t 60 -s $s -q 1024 -w randrw -M $m -c 1 -o $1 -L $lambda 
		done
		printf "\n" >> $1
	done
done
