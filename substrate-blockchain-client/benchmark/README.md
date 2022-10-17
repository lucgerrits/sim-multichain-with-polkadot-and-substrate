**State**: Working but need to fix batch sending issue.
# substrate-transaction-js becnhmark

Javascript client for Substrate.

**Note**: Ignore all other substrate-transaction-XXX projects ! Only the JS version of the client works fine.

## Dependencies

- polkadot-api
- TODO

## Init blockchain

```bash
#first create car and factories identities
./bin/genAccounts.js 5000 10 #5000 cars and 10 factories

#init the identities in the blockchain
./bin/ws/init.js
#this will add factory and cars public keys in the smart contract
```

## Start a benchmark

```bash
#to start a benchmark give the total transaction limit and transaction per second
./bin/ws/send.js 10000 100
#this will send 10k transactions at a 100tx/sec rate
```

### File description

- main scripts:
  - send.js
  - init.js
- sub process scripts:
  - sender.js
  - init_sender.js


**Note**: Ignore all other files !!!