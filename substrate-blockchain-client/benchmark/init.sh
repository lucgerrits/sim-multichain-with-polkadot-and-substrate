#!/usr/bin/env bash

./bin/ws/init_factories.js

echo "Wait block finalised"
sleep 30

./bin/ws/init_createVehicles.js

echo "Wait block finalised"
sleep 30

./bin/ws/init_initVehicles.js
