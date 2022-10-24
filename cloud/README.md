# Suvbstrate in the cloud

Note: can be used only for kubernetes type infras

## Prepare

### Generate the binaries for the relay-chain and parachains

```bash
cd ../substrate-blockchain-relay-chain/
cargo build --release

```

```bash
cd ../common-parachain-node/
cargo build --release
```

### Generate identities and configuration files

```bash
./deployments/genKeys.sh
```


We build the relay chain and parachains node chain specs & YAML. By default there is:
- 1 collator node per parachain
- 4 relay chain validators nodes
- 5 to 25 authority nodes in the parachain

```bash
./deployments/genChainspecsAndYaml.sh 5 #nb of parachain authority nodes
```


> Note: You should have at least two validators (relay chain nodes) running for every collator (parachain block authoring nodes) on your network. [link](https://docs.substrate.io/reference/how-to-guides/parachains/add-paranodes/)


## Deploy

### Monitoring

```bash
# WIP
```

### Prometheus

```bash
# WIP
```

### Deploy relay chain and parachains

```bash
./deployments/deploy.sh
```