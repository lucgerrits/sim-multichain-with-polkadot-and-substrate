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
    else
        relay_chain_endpoint=$1
fi
echo "Using endpoint: $relay_chain_endpoint"

cd ../ #to use config vars like other scripts

./scripts/re_add_parachains.js 2000 $relay_chain_endpoint
./scripts/re_add_parachains.js 3000 $relay_chain_endpoint


echo "STOP"