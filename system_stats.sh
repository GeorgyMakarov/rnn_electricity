#!/bin/bash

# Define usage thresholds
cpu_threshold='80'
mem_threshold='100'
dsk_threshold='90'

# Define monitoring functions

# --- cpu usage
# cpu_usage () {
#         cpu_idle=`top -b -n 1 | grep Cpu | awk '{print $8}' | cut -f 1 -d "."`
#         cpu_use=`expr 100 - $cpu_idle`
#         echo "cpu_utilization: $cpu_use"
# }
# cpu_usage

# Assign arguments
try_seed=123
k_seed=321
n_iters=`seq 5`

# Run R script and save its output to a file
for i in $n_iters
do
        result=`Rscript generate_temperature.R $try_seed $k_seed`
        # echo $result
        try_seed=`expr $try_seed + $i`
        k_seed=`expr $k_seed + $i`

        cpu_temp=`sensors | grep "^Core" | grep -e "+.*C" | cut -f 2 -d "+" | cut -f 1 -d " " |  sed 's/°C//'`
        echo $cpu_temp



done

exit 0
