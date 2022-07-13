# Rust Version of substrate client

```bash
#set requirements
rustup update
rustup update nightly
rustup default nightly
rustup target add wasm32-unknown-unknown --toolchain nightly

#build all the scripts
cargo build --release
```

## Set storage 

```bash
#run
./target/release/set_storage

#if need to give node endpoint
./target/release/set_storage -port 9944 -url ws://127.0.0.1
```
## Get storage

```bash
#run
./target/release/get_storage

#if need to give node endpoint
./target/release/get_storage -port 9944 -url ws://127.0.0.1
```

## Debug

To enable debut and view all in/out communications, execute the scripts with `RUST_LOG=debug` or `RUST_LOG=info`.

```bash
#example
RUST_LOG=debug ./target/release/get_storage
#example
RUST_LOG=info ./target/release/get_storage
```

### Cross-compile

Require the right toolchain: 
- ARM [here](https://developer.arm.com/tools-and-software/open-source-software/developer-tools/gnu-toolchain/gnu-a/downloads)
- RISC-V [here](https://github.com/riscv-collab/riscv-gnu-toolchain)

## requete de cross-complitaion

```bash
export CARGO_TARGET_ARMV7_UNKNOWN_LINUX_GNUEABIHF_LINKER=/usr/bin/arm-linux-gnueabihf-gcc
#target choisi armv7-unknown-linux-gnueabihf
rustup target add armv7-unknown-linux-gnueabihf
cargo build --release --target=armv7-unknown-linux-gnueabihf 
```

### Fonction de copie

```bash
scp -p @10.212.115.235:/home/lgerrits/Documents/substrate-blockchain-client/Rust/src/set_storage.rs pi@rasberrypi@10.212.125.36:/home/pi/Documents

scp -p @10.212.115.235:/home/lgerrits/Documents/substrate-blockchain-client/Rust/src/get_storage.rs pi@rasberrypi@10.212.125.36:/home/pi/Documents
```
ssh pi@10.212.125.36

