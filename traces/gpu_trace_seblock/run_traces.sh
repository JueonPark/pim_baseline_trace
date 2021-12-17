gap_list="seblock.py global_pooling.py"
fc_list="se_without_gap.py fully_connected.py relu.py sigmoid.py"
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }

# write scripts to each directory
traceconfig=/home/jueonpark/pim_baseline_trace/accel-sim-framework/gpu-simulator/configs/tested-cfgs/SM7_TITANV/trace.config
gpgpusimconfig=/home/jueonpark/pim_baseline_trace/accel-sim-framework/gpu-simulator/gpgpu-sim/configs/tested-cfgs/SM7_TITANV/gpgpusim.config

while IFS="," read -r channel row col 
do
  for i in $gap_list; do
    path="$i""_$channel""_$row""_$col"
    tracepath=/home/jueonpark/pim_baseline_trace/traces/gpu_trace_seblock/$path/traces/kernelslist.g
    echo "#!/bin/bash" >> ./$path/run.sh
    echo "/home/jueonpark/pim_baseline_trace/accel-sim-framework/gpu-simulator/bin/release/accel-sim.out -trace $tracepath -config $traceconfig -config $gpgpusimconfig" >> $path/run.sh
  done
done < ./gap_dimm.csv

while IFS="," read -r channel n
do
  for i in $fc_list; do
    path="$i""_$channel"
    tracepath=/home/jueonpark/pim_baseline_trace/traces/gpu_trace_seblock/$path/traces/kernelslist.g
    echo "#!/bin/bash" >> ./$path/run.sh
    echo "/home/jueonpark/pim_baseline_trace/accel-sim-framework/gpu-simulator/bin/release/accel-sim.out -trace $tracepath -config $traceconfig -config $gpgpusimconfig" >> $path/run.sh
  done
done < ./fc_dimm.csv

# run scripts
while IFS="," read -r channel row col 
do
  for i in $gap_list; do
    target="$i""_$channel""_$row""_$col"
    cd ./$target
    sbatch -J $target --exclude=g1 -o ./sim_result.out -e ./sim_result.err ./run.sh;
    cd ..
  done
done < ./gap_dimm.csv

while IFS="," read -r channel n
do
  for i in $fc_list; do
    target="$i""_$channel"
    cd ./$target
    sbatch -J $target --exclude=g1 -o ./sim_result.out -e ./sim_result.err ./run.sh;
    cd ..
  done
done < ./fc_dimm.csv