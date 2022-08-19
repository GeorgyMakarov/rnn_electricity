#!/bin/bash

# sensors | grep "^Core" | grep -e "+.*C" | cut -f 2 -d "+" | cut -f 1 -d " " |  sed 's/°C//'

a=`sensors coretemp-isa-0000 | grep -v "coretemp-isa-0000" | grep -v "Adapter: ISA adapter"`
echo "$a"

exit 0
