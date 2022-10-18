#!/usr/bin/env bash

cd "$(dirname "$0")"

#first create car and factories identities
./bin/genAccounts.js 5000 10 1000 #5000 cars , 10 factories , 1000 drivers

echo "Start init..."
sleep 1

./bin/renault/init_factories.js

echo "Wait block finalised"
sleep 30

./bin/renault/init_createVehicles.js

echo "Wait block finalised"
sleep 30

./bin/renault/init_initVehicles.js
