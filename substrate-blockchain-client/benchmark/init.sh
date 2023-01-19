#!/usr/bin/env bash

cd "$(dirname "$0")"

my_dir="$(dirname "$0")"

#include the config file:
chmod +x $my_dir/config.sh
source $my_dir/config.sh

#check and wait for chains to be ready
until ./bin/are_chains_ready.js $RELAYCHAIN_URL
do
    sleep 1
done

#first create car & drivers, factories
./bin/genAccounts.js 10000 50 #5000 10 #5000 cars and drivers, 10 factories

echo "Start init..."
sleep 1

################## Init renault chain

./bin/renault/init_factories.js $RENAULT_URL

echo "Wait block finalised"
sleep 30

./bin/renault/init_createVehicles.js $RENAULT_URL

echo "Wait block finalised"
sleep 30

./bin/renault/init_initVehicles.js $RENAULT_URL


################## Init insurance chain

./bin/insurance/init_signups.js $INSURANCE_URL

