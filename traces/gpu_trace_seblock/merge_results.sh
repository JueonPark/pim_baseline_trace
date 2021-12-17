gap_list="seblock.py global_pooling.py"
fc_list="se_without_gap.py fully_connected.py relu.py sigmoid.py"
[ ! -f $INPUT ] && { echo "$INPUT file not found"; exit 99; }

# run scripts
while IFS="," read -r channel row col 
do
  for i in $gap_list; do
    target="$i""_$channel""_$row""_$col"
    cp ./$target/accelwattch_power_report.log ./result/$target"_accelwattch_power_report.log"
    cp ./$target/sim_result.out ./result/$target"_sim_result.out"
  done
done < ./gap_dimm.csv

while IFS="," read -r channel n
do
  for i in $fc_list; do
    target="$i""_$channel"
    cp ./$target/accelwattch_power_report.log ./result/$target"_accelwattch_power_report.log"
    cp ./$target/sim_result.out ./result/$target"_sim_result.out"
  done
done < ./fc_dimm.csv