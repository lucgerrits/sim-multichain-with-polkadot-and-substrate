#!/usr/bin/env bash

cd "$(dirname "$0")"

# ============================================================
cd substrate-blockchain-relay-chain/

SECONDS=0

docker build -f Dockerfile-installed-focal -t projetsim/relaychain-node-local .
docker image tag projetsim/relaychain-node-local projetsim/relaychain-node

duration=$SECONDS
echo "Build substrate-blockchain-relay-chain image:"
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."

cd ../
# ============================================================
cd common-parachain-node/

SECONDS=0

docker build -f Dockerfile-installed-focal -t projetsim/parachain-node-local .
docker image tag projetsim/parachain-node-local projetsim/parachain-node

duration=$SECONDS
echo "Build common-parachain-node image:"
echo "$(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."