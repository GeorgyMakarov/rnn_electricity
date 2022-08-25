#!/bin/bash

# Define output format:
# elapsed time
# volume
# log diam
# average core temperature
# cpu usage before script
# cpu usage after script

# NB!: I might need to collect R command from 'top' process COMMAND column
# to identify the R related load only

# Assign arguments and constants
try_seed=123
k_seed=321
n_iters=`seq 20`
cpu_max=100.0

# Run main process and collect output data
for i in $n_iters
do
        # Collect cpu usage before script execution
        cpu_idle=`top -b -n 1 | grep Cpu | awk '{print $8}'| cut -f 1 -d "." | sed 's/,/\./'`
        cpu_usage_before=$(echo $cpu_max - $cpu_idle | bc -l)

        # Run Rscript process sim allows CPU temp to change over load
        # Result -- elapsed time, volume, log diam
        result=`Rscript generate_temperature.R $try_seed $k_seed`        
        try_seed=`expr $try_seed + $i`
        k_seed=`expr $k_seed + $i`
        
        # Average core temp allows to see how computation loaded CPU
        all_cores_t=`sensors | grep "^Core" | grep -e "+.*C" | cut -f 2 -d "+" | cut -f 1 -d " " |  sed 's/°C//'`
        let count=0
        sum=0.0

        for t in $all_cores_t
        do
                sum=$(echo $sum+$t | bc -l)
                let count+=1
        done
        temp=$(echo "$sum/$count" | bc -l)
        temp=${temp:0:6}

        # Append result with average temperature for better input
        result="${result} ${temp}"
        
        # Collect cpu usage after script execution
        cpu_idle=`top -b -n 1 | grep Cpu | awk '{print $8}'| cut -f 1 -d "." | sed 's/,/\./'`
        cpu_usage_after=$(echo $cpu_max - $cpu_idle | bc -l)

        # Append result with cpu usage
        result="${result} ${cpu_usage_before} ${cpu_usage_after}"
        echo $result

done

exit 0
