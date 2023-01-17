#!/bin/bash

cd "$(dirname "$0")"
source ./config.sh

if ! command -v node &> /dev/null
then
    echo "node could not be found"
    echo "Please install node: https://nodejs.org/en/download/package-manager/"
    exit
fi

#check if "npm install" has been done
DIR=./../node_modules
if [ -d "$DIR" ];
then
    echo "$DIR directory exists."
else
	echo "$DIR directory does not exist."
	echo "Please do: npm install"
    exit 1
fi


relay_chain_endpoint="ws://127.0.0.1:9944"
if [ -z "$1" ]
    then
        echo "No specific endpoint"
    else
        relay_chain_endpoint=$1
fi
echo "Using endpoint: $relay_chain_endpoint"

if [ -z "$2" ]
    then
        echo "No specific renault state path"
    else
        RENAULT_GENESIS_STATE_PATH=$2
fi
echo "Using renault state path: $RENAULT_GENESIS_STATE_PATH"

if [ -z "$3" ]
    then
        echo "No specific renault wasm path"
    else
        RENAULT_RUNTIME_WASM_PATH=$3
fi
echo "Using renault wasm path: $RENAULT_RUNTIME_WASM_PATH"

if [ -z "$4" ]
    then
        echo "No specific insurance state path"
    else
        INSURANCE_GENESIS_STATE_PATH=$4
fi
echo "Using insurance state path: $INSURANCE_GENESIS_STATE_PATH"

if [ -z "$5" ]
    then
        echo "No specific insurance wasm path"
    else
        INSURANCE_RUNTIME_WASM_PATH=$5
fi
echo "Using insurance wasm path: $INSURANCE_RUNTIME_WASM_PATH"

cd ../ #to use config vars like other scripts

echo "...waiting that relay chain started"
# sleep 90 #increase if parachains are not started fast enough !

./scripts/add_parachains.js 2000 $RENAULT_GENESIS_STATE_PATH $RENAULT_RUNTIME_WASM_PATH $relay_chain_endpoint
./scripts/add_parachains.js 3000 $INSURANCE_GENESIS_STATE_PATH $INSURANCE_RUNTIME_WASM_PATH $relay_chain_endpoint

echo "...waiting that parachains added"
sleep 90


# Build the HRMP channel
./scripts/build_HRMP_channel.js 2000 3000 $relay_chain_endpoint
sleep 30
./scripts/build_HRMP_channel.js 3000 2000 $relay_chain_endpoint

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