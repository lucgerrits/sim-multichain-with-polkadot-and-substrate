#!/bin/bash

cd "$(dirname "$0")"
#clean all before start
./clean_all.sh
source ./config.sh
cd ../../
cd ./substrate-blockchain-relay-chain
echo "------Start relay chain--------"
echo "------Start Alice validator--------"
# Start Relay `Alice` node
gnome-terminal --disable-factory --title="Validator Alice" -- ./target/release/polkadot \
                --alice \
                --node-key 0000000000000000000000000000000000000000000000000000000000000001 \
                --validator \
                --base-path "${RELAY_CHAIN_BASE_PATH}/alice" \
                --chain "${ROCCOCO_RAW_CHAIN_SPEC_PATH}" \
                --port 30333 \
                --rpc-cors=all \
                --ws-port 9944 &
PID_ALICE_RELAY=$!
echo "------Start Bob validator--------"
gnome-terminal --disable-factory --title="Validator Bob" -- ./target/release/polkadot \
                --bob \
                --validator \
                --base-path "${RELAY_CHAIN_BASE_PATH}/bob" \
                --chain "${ROCCOCO_RAW_CHAIN_SPEC_PATH}" \
                --bootnodes /ip4/127.0.0.1/tcp/30333/p2p/12D3KooWEyoppNCUx8Yx66oV9fJnriXwCcXwDDUA2kj6vnc6iDEp \
                --port 30334 \
                --rpc-cors=all \
                --ws-port 9945 &
PID_BOB_RELAY=$!
echo "------Start Charlie validator--------"
gnome-terminal --disable-factory --title="Validator Charlie" -- ./target/release/polkadot \
                --charlie \
                --validator \
                --base-path "${RELAY_CHAIN_BASE_PATH}/charlie" \
                --chain "${ROCCOCO_RAW_CHAIN_SPEC_PATH}" \
                --bootnodes /ip4/127.0.0.1/tcp/30333/p2p/12D3KooWEyoppNCUx8Yx66oV9fJnriXwCcXwDDUA2kj6vnc6iDEp \
                --port 30335 \
                --rpc-cors=all \
                --ws-port 9946 &
PID_CHARLIE_RELAY=$!
echo "------Start Dave validator--------"
gnome-terminal --disable-factory --title="Validator Dave" -- ./target/release/polkadot \
                --dave \
                --validator \
                --base-path "${RELAY_CHAIN_BASE_PATH}/dave" \
                --chain "${ROCCOCO_RAW_CHAIN_SPEC_PATH}" \
                --bootnodes /ip4/127.0.0.1/tcp/30333/p2p/12D3KooWEyoppNCUx8Yx66oV9fJnriXwCcXwDDUA2kj6vnc6iDEp \
                --port 30336 \
                --rpc-cors=all \
                --ws-port 9947 &
PID_DAVE_RELAY=$!

# this function is called when Ctrl-C is sent
function trap_ctrlc ()
{
    # perform cleanup here
    echo ""
    echo "Doing cleanup"
 
    kill -SIGHUP $PID_ALICE_RELAY
    kill -SIGHUP $PID_BOB_RELAY
    kill -SIGHUP $PID_CHARLIE_RELAY
    kill -SIGHUP $PID_DAVE_RELAY

    echo "STOP"

    # exit shell script with error code 2
    # if omitted, shell script will continue execution
    exit 2
}

trap "trap_ctrlc" 2

# idle waiting for abort from user
read -r -d '' _ </dev/tty