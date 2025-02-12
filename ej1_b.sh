#!/bin/bash


# Archivo de salida
output_file="data.txt"

# Configuración 1: 8KB, mapeo directo (1 vía)
echo "32kB_8via" >> "$output_file"
BENCHMARK="daxpy" PROCESSOR="in_order" ./filter_run_simulation.sh >> "$output_file"
echo "" >> "$output_file"

echo -e "\a"