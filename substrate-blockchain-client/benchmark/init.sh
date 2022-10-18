#!/usr/bin/env bash

cd "$(dirname "$0")"

#check and wait for chains to be ready
until ./bin/are_chains_ready.js
do
    echo .
    sleep 1
done

#first create car & drivers, factories
./bin/genAccounts.js 1000 10 #5000 10 #5000 cars and drivers, 10 factories

echo "Start init..."
sleep 1

################## Init renault chain

./bin/renault/init_factories.js

echo "Wait block finalised"
sleep 30

./bin/renault/init_createVehicles.js

echo "Wait block finalised"
sleep 30

./bin/renault/init_initVehicles.js


################## Init insurance chain

./bin/insurance/init_signups.js

