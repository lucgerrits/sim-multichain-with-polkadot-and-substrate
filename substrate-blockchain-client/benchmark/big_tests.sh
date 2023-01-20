#!/bin/bash


cd "$(dirname "$0")"

#RUN example:
#
#./big_test.sh <RANCHER TOKEN> > logs/test-"`date +"%Y-%m-%d-%T"`".log
#

GRAFANA_URL="http://grafana.unice.cust.tasfrance.com/api/annotations"
GRAFANA_DASHBOARD_ID="2"

JS_THREADS=20
arr_tests_tps=(10 50 100 200 400 600 1000 1500)
tot_cars=10000
tot_factories=10
total_accidents=30000

function send_annotation {
    curl -s -H "Content-Type: application/json" \
        -X POST \
        -u admin:admin1234  \
        -d "{\"tags\":[\"tests\", \"$4\"], \"dashboardId\":$GRAFANA_DASHBOARD_ID, \"text\":\"tps=$1,total=$2,test=$3,cars=$tot_cars,factories=$tot_factories,threads=$JS_THREADS\"}" \
        $GRAFANA_URL
    echo ""
}


for tps in "${arr_tests_tps[@]}"; do

    i=0

    cd ../../ # goto root folder

    ./cloud/deployments/delete-deployment.sh $1 #delete previous deployment
    sleep 5
    send_annotation "${tps}" "$total_tx" "${i}" "start_init_network"
    ./cloud/deployments/deploy.sh $1 #deploy new network
    send_annotation "${tps}" "$total_tx" "${i}" "end_init_network"
    sleep 5
    
    para_current_block=$(($(./cloud/deployments/get_current_block_number.sh) + 0 )) #get current block number and convert to int
    while [[ 10 -gt $para_current_block ]]
    do
        echo "Waiting for the network to be ready..."
        echo "Current block number: $para_current_block"
        sleep 1
        para_current_block=$(($(./cloud/deployments/get_current_block_number.sh) + 0 ))
    done

    send_annotation "${tps}" "$total_tx" "${i}" "start_init_test"
    ./substrate-blockchain-client/benchmark/init.sh $tot_cars $tot_factories
    send_annotation "${tps}" "$total_tx" "${i}" "end_init_test"
    sleep 10


    for i in {1..5}; do #repeat 5 times the test
        $start=$(./cloud/deployments/get_current_block_number.sh)
        echo ""
        echo "################### TEST tps=$tps n°$i #######################"
        send_annotation "${tps}" "$total_tx" "${i}" "start_send_accidents"
        ./substrate-blockchain-client/benchmark/benchmark.sh $total_accidents $tps $JS_THREADS #send accidents
        send_annotation "${tps}" "$total_tx" "${i}" "end_send_accidents"
        sleep 180
        $stop=$(./cloud/deployments/get_current_block_number.sh)

        echo "################### GET data tps=$tps n°$i #######################"
        node substrate-blockchain-client/Js/out/get_block_stats.js $start $stop "big_tests_${i}_" #get block stats

        # #Update gnuplot file
        # cd results/
        # gnuplot -p plot_block_logs_cloud.gnuplot
        # cd ../

    done

done
