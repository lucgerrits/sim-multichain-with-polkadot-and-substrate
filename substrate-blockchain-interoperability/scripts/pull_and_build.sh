#!/bin/bash

cd "$(dirname "$0")"
cd ../../
echo -e 'This scripts take a while...maybe grab a coffee ? \x00\xe2\x98\x95'

# [ -d "./substrate-blockchain-parachain-renault" ] && echo "Directory ./substrate-blockchain-parachain-renault exists" ||  git clone git@bitbucket.org:edge-team-leat/substrate-blockchain-parachain-renault.git
# [ -d "./substrate-blockchain-parachain-insurance" ] && echo "Directory ./substrate-blockchain-parachain-insurance exists" ||  git clone git@bitbucket.org:edge-team-leat/substrate-blockchain-parachain-mapfre.git ./substrate-blockchain-parachain-insurance #tmp fix for correct path, will change repo mapfre to insurance later
# [ -d "./substrate-blockchain-relay-chain" ] && echo "Directory ./substrate-blockchain-relay-chain exists" ||  git clone git@bitbucket.org:edge-team-leat/substrate-blockchain-relay-chain.git
echo "Build parachains" && \
cd ./common-parachain-node  && \
cargo build --release  && \
# cd ../ && \
# cd ./substrate-blockchain-parachain-insurance  && \
# cargo build --release  && \
cd ../ && \
echo "Build relay chain" && \
cd ./substrate-blockchain-relay-chain  && \
cargo build --release  && \
echo "ALL DONE"
