#!/bin/bash


cd "$(dirname "$0")"

#RUN example:
#
#./big_test.sh <RANCHER TOKEN> > logs/test-"`date +"%Y-%m-%d-%T"`".log
#

GRAFANA_URL="http://grafana.unice.cust.tasfrance.com/api/annotations"
GRAFANA_DASHBOARD_ID="2"

JS_THREADS=20
# arr_tests_tps=(10 50 100 200 400 600 1000 1500)
arr_tests_tps=(100 200 400 600 1000 1500)
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

cd ../../ # goto root folder

for tps in "${arr_tests_tps[@]}"; do
    total_accidents=$(($tps * 60 * 2)) #2 minutes
    if [ $total_accidents -gt 30000 ]; then
        total_accidents=30000 #max 30000 accidents
    fi
    echo "Total accidents: $total_accidents"
    i=0

    ./cloud/deployments/delete-deployment.sh $1 #delete previous deployment
    sleep 1
    send_annotation "${tps}" "$total_tx" "${i}" "start_init_network"
    ./cloud/deployments/deploy.sh $1 #deploy new network
    send_annotation "${tps}" "$total_tx" "${i}" "end_init_network"

    sleep 10
    send_annotation "${tps}" "$total_tx" "${i}" "start_init_test"
    ./substrate-blockchain-client/benchmark/init.sh $tot_cars $tot_factories

    number_of_zero_pending_tx=0
    while [[ $number_of_zero_pending_tx -lt 5 ]] #wait for 5 times 0 pending tx
    do
        echo "Waiting for pending transactions to be processed..."
        echo "Current pending transactions: $paras_total_pending_tx"
        sleep 1
        paras_total_pending_tx=$(($(node ./substrate-blockchain-client/Js/out/get_current_tx_queue.js "wss://relaychain.gerrits.xyz" "wss://renault.gerrits.xyz" "wss://insurance.gerrits.xyz") + 0 ))
        if [[ $paras_total_pending_tx -eq 0 ]]; then
            number_of_zero_pending_tx=$((number_of_zero_pending_tx + 1))
        else
            number_of_zero_pending_tx=0
        fi
    done

    send_annotation "${tps}" "$total_tx" "${i}" "end_init_test"

    # for i in {1..5}; do #repeat 5 times the test
        start=$(node ./substrate-blockchain-client/Js/out/get_current_block_number.js "wss://relaychain.gerrits.xyz" "wss://renault.gerrits.xyz" "wss://insurance.gerrits.xyz")
        echo ""
        echo "################### TEST tps=$tps n°$i #######################"
        send_annotation "${tps}" "$total_tx" "${i}" "start_send_accidents"
        ./substrate-blockchain-client/benchmark/benchmark.sh $total_accidents $tps $JS_THREADS #send accidents
        send_annotation "${tps}" "$total_tx" "${i}" "end_send_accidents"
        sleep 30

        number_of_zero_pending_tx=0
        while [[ $number_of_zero_pending_tx -lt 5 ]] #wait for 5 times 0 pending tx
        do
            echo "Waiting for pending transactions to be processed..."
            echo "Current pending transactions: $paras_total_pending_tx"
            sleep 1
            paras_total_pending_tx=$(($(node ./substrate-blockchain-client/Js/out/get_current_tx_queue.js "wss://relaychain.gerrits.xyz" "wss://renault.gerrits.xyz" "wss://insurance.gerrits.xyz") + 0 ))
            if [[ $paras_total_pending_tx -eq 0 ]]; then
                number_of_zero_pending_tx=$((number_of_zero_pending_tx + 1))
            else
                number_of_zero_pending_tx=0
            fi
        done


        stop=$(node ./substrate-blockchain-client/Js/out/get_current_block_number.js "wss://relaychain.gerrits.xyz" "wss://renault.gerrits.xyz" "wss://insurance.gerrits.xyz")

        echo "################### GET data tps=$tps n°$i #######################"
        #get block stats:
        node substrate-blockchain-client/Js/out/get_block_stats.js $start $stop "big_tests_${tps}tps_${i}_" "wss://relaychain.gerrits.xyz" "wss://renault.gerrits.xyz" "wss://insurance.gerrits.xyz"

        # #Update gnuplot file
        # cd results/
        # gnuplot -p plot_block_logs_cloud.gnuplot
        # cd ../

    # done
        ss notif "end test ${tps}tps"
done

echo "move files"
./results/move_files.sh

echo "Done"