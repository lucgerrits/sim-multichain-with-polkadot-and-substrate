#!/bin/bash

cd "$(dirname "$0")"
source ./config.sh

if ! command -v node &> /dev/null
then
    echo "node could not be found"
    echo "Please install node: https://nodejs.org/en/download/package-manager/"
    exit
fi

cd ../ #to use config vars like other scripts

echo "...waiting that relay chain started"
sleep 20 #increase if parachains are not started fast enough !

./scripts/add_parachains.js 2000 $RENAULT_GENESIS_STATE_PATH $RENAULT_RUNTIME_WASM_PATH
./scripts/add_parachains.js 3000 $INSURANCE_GENESIS_STATE_PATH $INSURANCE_RUNTIME_WASM_PATH

echo "...waiting that parachains added"
sleep 40

# Build the HRMP channel
./scripts/build_HRMP_channel.js 2000 3000
sleep 10
./scripts/build_HRMP_channel.js 3000 2000

echo "ALL DONE"

#Use the generated: was done already before, just use paths in config.sh
# - parachain genesis state
# - Wasm runtime validation function
#that was created in start_parachains.sh

# cd "$(dirname "$0")"
# cd ../../
# echo "------------------Renault parachain-------------------"
# cd ./substrate-blockchain-parachain-renault
# echo "-------Execute script to add parachains in relay chain-------"

# genesis=$(cat $renault_genesis_state_filename | tr -d '\n' | tr -d '\r') #get file content
# runtime=$(cat $renault_runtime_wasm_filename | tr -d '\n' | tr -d '\r') #get file content
# genesis="${genesis:2}"
# runtime="${runtime:2}"

# echo "{\"genesisHead\": \"${genesis}\", \"validationCode\": \"${runtime}\", \"parachain\": true}" > /tmp/SIM-multichain-with-polkadot-substrate/tmp_arg.txt

# polkadot-js-api \
#     --ws "ws://127.0.0.1:9944" \
#     --seed "//Alice" \
#     --sudo \
#     --sub \
#     tx.parasSudoWrapper.sudoScheduleParaInitialize \
#     "2000" \
#     @/tmp/SIM-multichain-with-polkadot-substrate/tmp_arg.txt


echo "STOP"