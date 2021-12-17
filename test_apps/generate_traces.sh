#!/bin/bash

export TRACER_TOOL=/home/jueonpark/cxl-simulator/multi_gpu_simulator/util/tracer_nvbit/tracer_tool/tracer_tool.so

SEDIR=./seblock
GAP_DIMM=./seblock/gap_dimm.csv
FC_DIMM=./seblock/fc_dimm.csv

gap_list="seblock.py global_pooling.py"
fc_list="se_without_gap.py fully_connected.py relu.py sigmoid.py"
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }

while IFS="," read -r channel row col 
do
  echo $channel
  echo $row
  echo $col
  for i in $gap_list; do
    echo "running $i with $channel, $row, $col" 
    LD_PRELOAD=$TRACER_TOOL python $SEDIR"/$i" --channel $channel --row $row --col $col
    mkdir "$i""_$channel""_$row""_$col"
    mv traces "$i""_$channel""_$row""_$col"
  done
done < $GAP_DIMM

while IFS="," read -r channel n
do
  echo $channel
  echo $row
  echo $col
  for i in $fc_list; do
    echo "running $i with $channel, $n"
    LD_PRELOAD=$TRACER_TOOL python $SEDIR"/$i" --channel $channel
    mkdir "$i""_$channel"
    mv traces "$i""_$channel"
  done
done < $FC_DIMM

undef $TRACER_TOOL

# postprocessing
export POST_PROCESSING=/home/jueonpark/cxl-simulator/multi_gpu_simulator/util/tracer_nvbit/tracer_tool/traces-processing/post-traces-processing

while IFS="," read -r channel row col 
do
  echo $channel
  echo $row
  echo $col
  for i in $gap_list; do
    echo "postprocessing $i, $channel, $row, $col" 
    $POST_PROCESSING ./"$i""_$channel""_$row""_$col"/traces/kernelslist
  done
done < $GAP_DIMM

while IFS="," read -r channel n
do
  echo $channel
  for i in $fc_list; do
    echo "postprocessing $i, $channel"
    $POST_PROCESSING ./"$i""_$channel"/traces/kernelslist
  done
done < $FC_DIMM
