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


#check and wait for chains to be ready
until ./bin/are_chains_ready.js
do
    echo .
    sleep 1
done

# read -p "Are you sure? (y/n)" -n 1 -r
# echo    # (optional) move to a new line
# if [[ $REPLY =~ ^[Yy]$ ]]
# then
    echo "Starting..."
    ./bin/renault/report_accident.js $TOTAL_TX $TX_PER_SEC $THREADS

# else
#     echo "Stopping..."
# fi
