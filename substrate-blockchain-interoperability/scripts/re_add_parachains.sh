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
    # echo "$DIR directory exists."
    echo "."
else
	echo "$DIR directory does not exist."
	echo "Please do: npm install"
    exit 1
fi


relay_chain_endpoint="ws://127.0.0.1:9944"
if [ -z "$1" ]
    then
        echo "No specific endpoint"
        echo "You can change it using: ./scripts/re_add_parachains.sh <endpoint>"
        echo "Example: ./scripts/re_add_parachains.sh 'wss://relaychain.gerrits.xyz'"
    else
        relay_chain_endpoint=$1
fi
echo "Using endpoint: $relay_chain_endpoint"
sleep 1

cd ../ #to use config vars like other scripts

./scripts/re_add_parachains.js 2000 $relay_chain_endpoint
./scripts/re_add_parachains.js 3000 $relay_chain_endpoint

echo "...waiting that parachains added"
sleep 90

# Build the HRMP channel
./scripts/build_HRMP_channel.js 2000 3000 $relay_chain_endpoint
sleep 30
./scripts/build_HRMP_channel.js 3000 2000 $relay_chain_endpoint

echo "STOP"