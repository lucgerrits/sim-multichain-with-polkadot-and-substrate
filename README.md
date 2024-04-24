# Multichain interoperability project

Project struture:

- `substrate-blockchain-interoperability/`: the main project folder, containing automated startip scripts, some documentation and project state.
- `substrate-blockchain-client/`: All the code to run the client code (e.g. send transactions) in JS.
- `common-parachain-node/`: Renault and Insurance parachain node with its pallets. 
>Note:
> For simplicity, insurance and renault parachains are installed with the same code, but with different configurations.
> In real situation each would contain of course different code and logic.
> 
**Note**: To start just go to `substrate-blockchain-interoperability/` first.


## Install, start, test, etc

Look at: [substrate-blockchain-interoperability/README.md](substrate-blockchain-interoperability/README.md)