#!/bin/bash

# Script to precondition SSD
# June 2016

# Parameters:
# 	$1 = output filename


if [ $# -ne 1 ]
  then
    echo "Usage: ./precondition.sh [output_filename]"
fi

# Create output file and set permissions for root to write
touch $1
chmod o+w $1


# Write sequentially (should be done to whole address space of device)
sudo ./perf -t 1000 -s 131072 -q 16 -w write -c 1 -p 1

# Write randomly to device 
printf "Workload; Read Ratio; Num cores; Qdepth; Req Size; Target IOPS; Rd IOPS; Wr IOPS; Rd Avg; Rd p95; Rd p99; Wr Avg; Wr p95; Wr p99; ; #dropped \n" >> $1
printf "randwrite-precond-step2; 0; 1; 128; 4069; N/A;" >> $1
sudo ./perf -t 1000 -s 4096 -q 128 -w randwrite -c 1 -o $1

# Now run performance tests using run_perf.sh to check that have reached steady state, should have repeatable results

