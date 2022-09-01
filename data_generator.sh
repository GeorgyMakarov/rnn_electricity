#!/bin/bash

n_iter=`seq 1000`
count_step=100
try_seed=123
k_seed=321
cpu_max=100.0
raw_data="raw_data.txt"

if [ -e $raw_data ]; then
  rm $raw_data
fi

touch $raw_data

for i in $n_iter
do
  
  # Collect CPU usage before starting the script
  cpu_idle=`top -bn 1 | grep '%Cpu(s):' | tr -d ' ' | grep -o -P '.{0,4}id' | tr -d 'id' | sed 's/,/\./'`
  cpu_usage_before=$(echo $cpu_max - $cpu_idle | bc -l)
  
  
  # Run main process script to generate CPU load and temperature
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
  result="${result} ${temp}"
  
  
  # Collect cpu usage after script execution
  cpu_idle=`top -bn 1 | grep '%Cpu(s):' | tr -d ' ' | grep -o -P '.{0,4}id' | tr -d 'id' | sed 's/,/\./'`
  cpu_usage_after=$(echo $cpu_max - $cpu_idle | bc -l)
  
  
  # Return all results
  result="${result} ${cpu_usage_before} ${cpu_usage_after}"
  echo $result >> $raw_data
  
  test_i=$(( i % count_step == 0 ))
  
  if [ $test_i == 1 ]; then
    tst=`date +%T`
    msg="executing step"
    say="$msg $i $tst"
    echo $say
  fi
  
done

exit 0
