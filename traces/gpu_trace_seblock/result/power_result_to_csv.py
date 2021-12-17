import re
import os
import csv
import glob

accelwattch_file_list = glob.glob("*.log")

# workload_name, kernel_number, avg_power, max_power, min_power

csv_contents = []
for file in accelwattch_file_list:
  # print("file: " + file)
  with open(file, 'r') as accelwattch_file:
    kernel = 1
    lines = accelwattch_file.readlines()
    row_data = []
    for line in lines:
      if "Accumulative Power Statistics Over Previous Kernels" in line:
        # print("kernel: " + str(kernel))
        # print(line)
        row_data.append(file)
        row_data.append(kernel)
      elif "gpu_tot_avg_power" in line:
        # print(line)
        row_data.append(float(line.split("=")[1]))
      elif "gpu_tot_max_power" in line:
        # print(line)
        row_data.append(float(line.split("=")[1]))
      elif "gpu_tot_min_power" in line:
        # print(line)
        row_data.append(float(line.split("=")[1]))
        csv_contents.append(row_data)
        kernel += 1
        row_data = []

accelwattch_result = open("accelwattch_result.csv", "w+")
result_writer = csv.writer(accelwattch_result)
result_writer.writerow(["filename", "kernel_num", "avg_power", "max_power", "min_power"])
result_writer.writerows(csv_contents)
accelwattch_result.close()