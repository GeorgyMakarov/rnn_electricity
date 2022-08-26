#!/bin/bash

# Define output format:
# elapsed time
# volume
# log diam
# average core temperature
# cpu usage before script
# cpu usage after script

# Assign arguments and constants
try_seed=123
k_seed=321
n_iters=`seq 10`
cpu_max=100.0
raw_data="raw_data.txt"

# Create output file
if [ -e $raw_data ]; then
        rm $raw_data
        echo "removing existing raw data file"
fi

touch $raw_data

# Run main process and collect output data
for i in $n_iters
do
        # Collect cpu usage before script execution
        cpu_idle=`top -b -n 1 | grep Cpu | awk '{print $8}'| cut -f 1 -d "." | sed 's/,/\./'`
        cpu_usage_before=$(echo $cpu_max - $cpu_idle | bc -l)
        cpu_usage_before=$(echo $cpu_usage_before + 0.0 | bc -l)

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
        cpu_usage_after=$(echo $cpu_usage_after + 0.0 | bc -l)

        # Append result with cpu usage
        result="${result} ${cpu_usage_before} ${cpu_usage_after}"
        echo $result >> $raw_data      

        if (( $i % 5 == 0 ));
        then
                msg="simulation step"
                msg="$msg $i"
                time_stamp=`date`
                msg="$msg $time_stamp"
                echo $msg
        fi

done

exit 0
