#!/bin/bash

export TRACER_TOOL=/home/jueonpark/cxl-simulator/multi_gpu_simulator/util/tracer_nvbit/tracer_tool/tracer_tool.so

SEDIR=./seblock
GAP_DIMM=./seblock/gap_dimm.csv
FC_DIMM=./seblock/fc_dimm.csv

fc_list="se_without_gap.py"
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }

while IFS="," read -r channel n
do
  echo $channel
  echo $n
  echo "running $i with $channel, $n"
  LD_PRELOAD=$TRACER_TOOL python $SEDIR"/se_without_gap.py" --channel $channel
  mkdir "se_without_gap.py_$channel"
  mv traces "se_without_gap.py_$channel"
done < $FC_DIMM

undef $TRACER_TOOL

# postprocessing
export POST_PROCESSING=/home/jueonpark/cxl-simulator/multi_gpu_simulator/util/tracer_nvbit/tracer_tool/traces-processing/post-traces-processing

while IFS="," read -r channel n
do
  echo $channel $n
  echo "postprocessing se_without_gap.py_$channel"
  $POST_PROCESSING ./"se_without_gap.py_$channel"/traces/kernelslist
done < $FC_DIMM
