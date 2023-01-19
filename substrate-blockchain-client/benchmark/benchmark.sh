#!/usr/bin/env bash

TOTAL_TX=$1
TX_PER_SEC=$2
THREADS=$3


echo "Benchmark program for Substrate JS client"

echo "----------------------------------------------------"
echo "Threads: $THREADS"
echo "Average tx/sec: $TX_PER_SEC"
echo "Total tx: $TOTAL_TX"
echo "----------------------------------------------------"

if [ "$#" -ne 3 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

my_dir="$(dirname "$0")"

#include the config file:
chmod +x $my_dir/config.sh
source $my_dir/config.sh

#check and wait for chains to be ready
until ./bin/are_chains_ready.js
do
    sleep 1
done

echo "Starting..."
./bin/report_accident.js $TOTAL_TX $TX_PER_SEC $THREADS "report_accident_renault" $RENAULT_URL
sleep 30
./bin/report_accident.js $TOTAL_TX $TX_PER_SEC $THREADS "report_accident_insurance" $INSURANCE_URL

echo "Done benchmark"