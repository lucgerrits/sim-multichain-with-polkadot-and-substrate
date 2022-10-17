#!/usr/bin/env bash

WAIT_TIME=1 # wait itme (in seconds) in each loop before sending next tx
# WAIT_TIME=$(printf %.10f\\n "$((10**9 * 20/7))e-9")
THREADS=10 # number of simulataneous loop execution
TX_PER_THREAD=100 

TX_PER_SEC=$(echo "$THREADS * $WAIT_TIME" | bc -l | awk '{printf "%.1f", $0}')
TOTAL_TX=$(($THREADS * $TX_PER_THREAD))

echo "Benchmark program for Substrate JS client"

echo "----------------------------------------------------"
echo "Wait time: $WAIT_TIME"
echo "Threads: $THREADS"
echo "Average tx/sec: $TX_PER_SEC"
echo "Total tx: $TOTAL_TX"
echo "----------------------------------------------------"


read -p "Are you sure? (y/n)" -n 1 -r
echo    # (optional) move to a new line
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Starting..."
    for i in $(seq 1 $TX_PER_THREAD); do 
        for tx_n in {1..5}; do 
            echo -e "Thread $tx_n $(echo '\t') Tx $i " & node ./out.js &
        done
        sleep $WAIT_TIME
    done

else
    echo "Stopping..."
fi
