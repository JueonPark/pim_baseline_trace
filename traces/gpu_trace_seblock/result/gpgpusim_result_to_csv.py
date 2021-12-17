import re
import os
import csv
import glob

gpgpusim_file_list = glob.glob("*.out")

# workload_name, kernel_number, avg_power, max_power, min_power

csv_contents = []
for file in gpgpusim_file_list:
  # print("file: " + file)
  with open(file, 'r') as gpgpusim_file:
    kernel = 1
    lines = gpgpusim_file.readlines()
    row_data = []
    for line in lines:
      if "kernel_name" in line:
        # print("kernel: " + str(kernel))
        # print(line)
        row_data.append(file)
        row_data.append(kernel)
      elif "gpu_tot_sim_cycle" in line:
        # print(line)
        row_data.append(int(line.split("=")[1]))
        csv_contents.append(row_data)
        kernel += 1
        row_data = []

gpgpusim_result = open("gpgpusim_result.csv", "w+")
result_writer = csv.writer(gpgpusim_result)
result_writer.writerow(["filename", "kernel_num", "gpu_tot_sim_cycle"])
result_writer.writerows(csv_contents)
gpgpusim_result.close()