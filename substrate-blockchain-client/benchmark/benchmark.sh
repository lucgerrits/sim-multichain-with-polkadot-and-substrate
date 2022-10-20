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

#check and wait for chains to be ready
until ./bin/are_chains_ready.js
do
    sleep 1
done

echo "Starting..."
./bin/report_accident.js $TOTAL_TX $TX_PER_SEC $THREADS "report_accident_renault"
sleep 30
./bin/report_accident.js $TOTAL_TX $TX_PER_SEC $THREADS "report_accident_insurance"

echo "Done benchmark"