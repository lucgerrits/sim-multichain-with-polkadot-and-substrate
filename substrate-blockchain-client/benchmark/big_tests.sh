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
# arr_tests_tps=(10 200 1000 1500)
# arr_tests_collators=(1 2 3)
arr_tests_collators=(1 2 3)
tot_cars=10000
tot_factories=10
total_accidents=10000
TEST_LABEL_PREFIX="oh_yeay_" #prefix for the CSV files results
#number of collators, this is only to label the CSV files results !!
#Change the number of collators in the genParachainCollatorYaml.sh file
#example: declare -a accounts=("alice" "bob" "charlie")
# LABEL_NB_COLLATORS=3

ENABLE_PERSONAL_NOTIFICATIONS=true #true or false

function send_annotation {
    curl -s -H "Content-Type: application/json" \
        -X POST \
        -u admin:admin1234  \
        -d "{\"tags\":[\"tests\", \"$4\"], \"dashboardId\":$GRAFANA_DASHBOARD_ID, \"text\":\"tps=$1,total=$2,test=$3,cars=$tot_cars,factories=$tot_factories,threads=$JS_THREADS\"}" \
        $GRAFANA_URL
    echo ""
}

cd ../../ # goto root folder

for collators in "${arr_tests_collators[@]}"; do
    for tps in "${arr_tests_tps[@]}"; do
        if $ENABLE_PERSONAL_NOTIFICATIONS; then
            ss notif "Start ${tps}tps (${collators} collators)"
        fi
        success_iteration=0
        while [[ $success_iteration -eq 0 ]]
        do
            # total_accidents=$(($tps * 60 * 2)) #2 minutes
            # if [ $total_accidents -gt 30000 ]; then
            #     total_accidents=30000 #max 30000 accidents
            # fi
            echo "Total accidents: $total_accidents"
            i=0

            ./cloud/deployments/delete-deployment.sh $1 #delete previous deployment
            sleep 1
            send_annotation "${tps}" "$total_accidents" "${i}" "start_init_network"
            ./cloud/deployments/deploy.sh $1 $collators #deploy new network
            send_annotation "${tps}" "$total_accidents" "${i}" "end_init_network"

            sleep 20 #wait for nodes to be ready
            send_annotation "${tps}" "$total_accidents" "${i}" "start_init_test"
            ./substrate-blockchain-client/benchmark/init.sh $tot_cars $tot_factories

            number_of_zero_pending_tx=0
            number_of_loops=0
            #if we have 30 times 0 pending tx, we can exit the while loop
            while [[ $number_of_zero_pending_tx -lt 30 ]]
            do
                echo "#$number_of_loops Waiting for pending transactions to be processed...Current pending transactions: $paras_total_pending_tx"
                sleep 1
                paras_total_pending_tx=$(($(node ./substrate-blockchain-client/Js/out/get_current_tx_queue.js "wss://relaychain.gerrits.xyz" "wss://renault.gerrits.xyz" "wss://insurance.gerrits.xyz") + 0 ))
                if [[ $paras_total_pending_tx -eq 0 ]]; then
                    #if pending tx is 0, we increment the counter
                    number_of_zero_pending_tx=$((number_of_zero_pending_tx + 1))
                else
                    number_of_zero_pending_tx=0 #reset counter
                fi

                number_of_loops=$((number_of_loops + 1))
                if [[ $number_of_loops -gt 500 ]]; then #5 minutes
                    #if we have more than 500 loops, we exit the while loop and retry the entire test
                    echo "Timeout: 500 seconds"
                    echo "Probably a node is down, retrying the entire test..."
                    success_iteration=0 #failure iteration, so we can retry the entire test
                    break #exit the pending tx while loop
                else
                    success_iteration=1 #success iteration, so we can exit the while loop
                fi
            done
            if [[ $success_iteration -eq 0 ]]; then
                if $ENABLE_PERSONAL_NOTIFICATIONS; then
                    ss notif "Timeout ${tps}tps (${collators} collators) - retrying"
                fi
                send_annotation "${tps}" "$total_accidents" "${i}" "node_fail_detected"
                continue #retry the entire test
            fi

            send_annotation "${tps}" "$total_accidents" "${i}" "end_init_test"

            # for i in {1..5}; do #repeat 5 times the test
                start=$(node ./substrate-blockchain-client/Js/out/get_current_block_number.js "wss://relaychain.gerrits.xyz" "wss://renault.gerrits.xyz" "wss://insurance.gerrits.xyz")
                echo ""
                echo "################### TEST tps=$tps n°$i #######################"
                send_annotation "${tps}" "$total_accidents" "${i}" "start_send_accidents"
                ./substrate-blockchain-client/benchmark/benchmark.sh $total_accidents $tps $JS_THREADS #send accidents

                number_of_zero_pending_tx=0
                number_of_loops=0
                #if we have 30 times 0 pending tx, we can exit the while loop
                while [[ $number_of_zero_pending_tx -lt 30 ]]
                do
                    echo "#$number_of_loops Waiting for pending transactions to be processed...Current pending transactions: $paras_total_pending_tx"
                    sleep 1
                    #because of the kubernetes ingress, sometimes the node requested has no pending tx but the other nodes may have pending tx
                    paras_total_pending_tx=$(($(node ./substrate-blockchain-client/Js/out/get_current_tx_queue.js "wss://relaychain.gerrits.xyz" "wss://renault.gerrits.xyz" "wss://insurance.gerrits.xyz") + 0 ))
                    if [[ $paras_total_pending_tx -eq 0 ]]; then
                        #if pending tx is 0, we increment the counter
                        number_of_zero_pending_tx=$((number_of_zero_pending_tx + 1))
                    else
                        number_of_zero_pending_tx=0 #reset counter
                    fi

                    number_of_loops=$((number_of_loops + 1))
                    if [[ $number_of_loops -gt 600 ]]; then #10 minutes
                        #if we have more than 600 loops, we exit the while loop and retry the entire test
                        echo "Timeout: 600 seconds"
                        echo "Probably a node is down, retrying the entire test..."
                        success_iteration=0 #failure iteration, so we can retry the entire test
                        break #exit the pending tx while loop
                    else
                        success_iteration=1 #success iteration, so we can exit the while loop
                    fi
                done
                if [[ $success_iteration -eq 0 ]]; then
                    if $ENABLE_PERSONAL_NOTIFICATIONS; then
                        ss notif "Timeout ${tps}tps (${collators} collators) - retrying"
                    fi
                    send_annotation "${tps}" "$total_accidents" "${i}" "node_fail_detected"
                    continue #retry the entire test
                fi
            
                send_annotation "${tps}" "$total_accidents" "${i}" "end_send_accidents"
                sleep 30

                stop=$(node ./substrate-blockchain-client/Js/out/get_current_block_number.js "wss://relaychain.gerrits.xyz" "wss://renault.gerrits.xyz" "wss://insurance.gerrits.xyz")

                echo "################### GET data tps=$tps n°$i #######################"
                #get block stats:
                node substrate-blockchain-client/Js/out/get_block_stats.js $start $stop "${TEST_LABEL_PREFIX}_${collators}collator_${tps}tps_${i}_" "wss://relaychain.gerrits.xyz" "wss://renault.gerrits.xyz" "wss://insurance.gerrits.xyz"

            # done
                success_iteration=1 #success iteration, so we can exit the while loop
        done
        if $ENABLE_PERSONAL_NOTIFICATIONS; then
            ss notif "Done ${tps}tps (${collators} collators)"
        fi
    done
        if $ENABLE_PERSONAL_NOTIFICATIONS; then
            ss notif "Done ${collators} collators"
        fi
done

# echo "move files"
# ./results/move_files.sh
ss notif "Done all tests"

echo "Done"