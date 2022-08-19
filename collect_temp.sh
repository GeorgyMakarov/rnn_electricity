#!/bin/bash

a=`sensors coretemp-isa-0000 | grep -v "coretemp-isa-0000" | grep -v "Adapter: ISA adapter"`
echo "$a"

exit 0
