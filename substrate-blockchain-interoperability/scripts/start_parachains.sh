#!/bin/bash

cd "$(dirname "$0")"
source ./config.sh

if ! command -v jq &> /dev/null
then
    echo "jq could not be found"
    echo "Please install with: sudo apt install jq"
    exit
fi

cd ../../

para_id=2000

echo "------Renault parachain/collator node------"
cd ./common-parachain-node
echo "------Custom parachain specification------"
./target/release/parachain-collator build-spec --disable-default-bootnode > $RENAULT_CHAIN_SPEC_PATH
####### chain spec build #######
#edit the chain spec
chainSpec=$(cat $RENAULT_CHAIN_SPEC_PATH) #get file content
chainSpec=$(echo $chainSpec | jq '.name = "Renault Chain"')
chainSpec=$(echo $chainSpec | jq '.id = "renault_chain_testnet"')
chainSpec=$(echo $chainSpec | jq '.para_id = '${para_id}'')
chainSpec=$(echo $chainSpec | jq '.genesis.runtime.parachainInfo.parachainId = '${para_id}'')
echo $chainSpec | jq > $RENAULT_CHAIN_SPEC_PATH #write changes to file

./target/release/parachain-collator build-spec --chain $RENAULT_CHAIN_SPEC_PATH --raw --disable-default-bootnode > $RENAULT_RAW_CHAIN_SPEC_PATH

echo "------Generate a parachain genesis state------"
./target/release/parachain-collator export-genesis-state --chain $RENAULT_RAW_CHAIN_SPEC_PATH > $RENAULT_GENESIS_STATE_PATH
echo "------Obtain Wasm runtime validation function------"
./target/release/parachain-collator export-genesis-wasm --chain $RENAULT_RAW_CHAIN_SPEC_PATH > $RENAULT_RUNTIME_WASM_PATH

echo "------Start the Renault parachain/collator node------"
####### run the final cmd to start collator #######
gnome-terminal --disable-factory --title="Renault Parachain/Collator node" -- ./target/release/parachain-collator \
            --offchain-worker "always" \
            --collator \
            --name "Renault Parachain" \
            -lsync=info \
            --alice \
            --force-authoring \
            --base-path ${RENAULT_BASE_PATH} \
            --port 40333 \
            --ws-port 8844 \
            --pruning archive \
            --rpc-cors=all \
            --chain ${RENAULT_RAW_CHAIN_SPEC_PATH} \
            -- \
            --execution wasm \
            --name "Renault Collator" \
            --chain ${ROCCOCO_RAW_CHAIN_SPEC_PATH} \
            --port 30343 \
            --ws-port 9977 &

PID_RENAULT_COLLATOR=$!

cd ../

para_id=3000

echo "------Insurance parachain/collator node------"
cd ./common-parachain-node
echo "------Custom parachain specification------"
./target/release/parachain-collator build-spec --disable-default-bootnode > $INSURANCE_CHAIN_SPEC_PATH
####### chain spec build #######
#edit the chain spec
chainSpec=$(cat $INSURANCE_CHAIN_SPEC_PATH) #get file content
chainSpec=$(echo $chainSpec | jq '.name = "Insurance Chain"')
chainSpec=$(echo $chainSpec | jq '.id = "insurance_chain_testnet"')
chainSpec=$(echo $chainSpec | jq '.para_id = '${para_id}'')
chainSpec=$(echo $chainSpec | jq '.genesis.runtime.parachainInfo.parachainId = '${para_id}'')
echo $chainSpec | jq > $INSURANCE_CHAIN_SPEC_PATH #write changes to file

./target/release/parachain-collator build-spec --chain $INSURANCE_CHAIN_SPEC_PATH --raw --disable-default-bootnode > $INSURANCE_RAW_CHAIN_SPEC_PATH

echo "------Generate a parachain genesis state------"
./target/release/parachain-collator export-genesis-state --chain $INSURANCE_RAW_CHAIN_SPEC_PATH > $INSURANCE_GENESIS_STATE_PATH
echo "------Obtain Wasm runtime validation function------"
./target/release/parachain-collator export-genesis-wasm --chain $INSURANCE_RAW_CHAIN_SPEC_PATH > $INSURANCE_RUNTIME_WASM_PATH

echo "------Start the Insurance parachain/collator node------"
####### run the final cmd to start collator #######
gnome-terminal --disable-factory --title="Insurance Parachain/Collator node" -- ./target/release/parachain-collator \
            --collator \
            --name "Insurance Parachain" \
            --alice \
            --force-authoring \
            --base-path ${INSURANCE_BASE_PATH} \
            --port 40332 \
            --ws-port 8843 \
            --pruning archive \
            --rpc-cors=all \
            --chain ${INSURANCE_RAW_CHAIN_SPEC_PATH} \
            -- \
            --execution wasm \
            --name "Insurance Collator" \
            --chain ${ROCCOCO_RAW_CHAIN_SPEC_PATH} \
            --port 30342 \
            --ws-port 9976 &

PID_INSURANCE_COLLATOR=$!



# cd ../
# echo "------Mapfre parachain/collator node------"
# cd ./substrate-blockchain-parachain-mapfre
# echo "------Generate a parachain genesis state------"
# ./target/release/parachain-collator export-genesis-state --parachain-id 3000 > "$mapfre_genesis_state_filename"
# echo "------Obtain Wasm runtime validation function------"
# ./target/release/parachain-collator export-genesis-wasm > "$mapfre_runtime_wasm_filename"
# echo "------Start the insurance parachain/collator node------"
# ####### chain spec build #######
# #first get chain spec
# chainSpec=$(cat $roccoco_raw_chain_spec_location) #get file content
# chainSpec=$(echo $chainSpec | jq '.name = "Mapfre Chain"')
# chainSpec=$(echo $chainSpec | jq '.id = "mapfre_chain_testnet"')
# echo $chainSpec | jq > $mapfre_raw_chain_spec_location #write changes to file

# ####### run the final cmd to start collator #######
# gnome-terminal --disable-factory --title="Insurance Parachain/Collator node" -- ./target/release/parachain-collator \
#             --bob \
#             --collator \
#             --force-authoring \
#             --parachain-id 3000 \
#             --base-path $MAPFRE_BASE_PATH \
#             --port 40332 \
#             --ws-port 8843 \
#             -- \
#             --execution wasm \
#             --chain "$roccoco_raw_chain_spec_location" \
#             --port 30342 \
#             --ws-port 9976 &



# this function is called when Ctrl-C is sent
function trap_ctrlc ()
{
    # perform cleanup here
    echo ""
    echo "Doing cleanup"
 
    kill -SIGHUP $PID_RENAULT_COLLATOR
    kill -SIGHUP $PID_INSURANCE_COLLATOR

    echo "STOP"

    # exit shell script with error code 2
    # if omitted, shell script will continue execution
    exit 2
}

trap "trap_ctrlc" 2

# idle waiting for abort from user
read -r -d '' _ </dev/tty