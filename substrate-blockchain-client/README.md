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
node substrate-blockchain-client/Js/out/get_block_stats.js
```

Or:

```bash
node substrate-blockchain-client/Js/out/get_block_stats.js <number>

#<number> = get the last X blocks
```
