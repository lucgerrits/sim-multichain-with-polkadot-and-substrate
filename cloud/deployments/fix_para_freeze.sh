#!/bin/bash

cd "$(dirname "$0")"

#include the config file:
chmod +x config.sh
source config.sh

echo "Fixing freezing parachains by re adding them as parachains"

./../../substrate-blockchain-interoperability/scripts/re_add_parachains.sh "wss://relaychain.gerrits.xyz"

echo "Done"