# Relay chain config
ROCCOCO_RAW_CHAIN_SPEC_PATH=../substrate-blockchain-interoperability/chainspecs/rococo-custom-2-raw.json
RELAY_CHAIN_BASE_PATH=/tmp/SIM-multichain-with-polkadot-substrate/relay-chain
RELAY_CHAIN_CHAIN_SPEC_PATH=../substrate-blockchain-interoperability/chainspecs/relay-chain.json
RELAY_CHAIN_RAW_CHAIN_SPEC_PATH=../substrate-blockchain-interoperability/chainspecs/relay-chain-raw.json
# ports are from 30333 to 30336
# ws ports are from 9944 to 9947


############ Renault config
RENAULT_CHAIN_SPEC_PATH=../substrate-blockchain-interoperability/chainspecs/renault-chain.json
RENAULT_RAW_CHAIN_SPEC_PATH=../substrate-blockchain-interoperability/chainspecs/renault-chain-raw.json
RENAULT_BASE_PATH=/tmp/SIM-multichain-with-polkadot-substrate/parachain/renault

RENAULT_GENESIS_STATE_PATH=../substrate-blockchain-parachain-renault/para-2000-genesis
RENAULT_RUNTIME_WASM_PATH=../substrate-blockchain-parachain-renault/para-2000-wasm

# ports are: 
# - collator 40333
# - relay chain 30343

# ws ports are:
# - collator 8844
# - relay chain 9977

############ Insurance config
INSURANCE_CHAIN_SPEC_PATH=../substrate-blockchain-interoperability/chainspecs/insurance-chain.json
INSURANCE_RAW_CHAIN_SPEC_PATH=../substrate-blockchain-interoperability/chainspecs/insurance-chain-raw.json
INSURANCE_BASE_PATH=/tmp/SIM-multichain-with-polkadot-substrate/parachain/insurance

INSURANCE_GENESIS_STATE_PATH=../substrate-blockchain-parachain-insurance/para-3000-genesis
INSURANCE_RUNTIME_WASM_PATH=../substrate-blockchain-parachain-insurance/para-3000-wasm

# ports are: 
# - collator 40332
# - relay chain 30342

# ws ports are:
# - collator 8843
# - relay chain 9976