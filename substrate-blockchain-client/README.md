# Clients for substrate

State of the clients:

- Js: ok


## Usage

First compile the TS using the vscode task run command called "tsc: build ....".

The termianl should show:
```
 *  Executing task: tsc -p /media/lgerrits/Data/github/sim-multichain-with-polkadot-and-substrate/substrate-blockchain-client/Js/tsconfig.json 

 *  Terminal will be reused by tasks, press any key to close it. 
```



Important:

> Go to project root directory.


```bash
node substrate-blockchain-client/Js/out/get_block_stats.js <start_block> <end_block> <output_file_prefix> <relaychain_url> <renault_url> <insurance_url>
#ex:
node get_block_stats.js 450 400 "my_test_100tps_" "wss://relaychain.gerrits.xyz" "wss://renault.gerrits.xyz" "wss://insurance.gerrits.xyz"

```