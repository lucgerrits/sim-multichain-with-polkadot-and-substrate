# Substrate Node

## Build the node

### Requirements

First install some tools and libs:

| OS               | Installation commands                                                             |
|------------------|-----------------------------------------------------------------------------------|
| Ubuntu or Debian | sudo apt update && sudo apt install -y git clang curl libssl-dev llvm libudev-dev |
| Arch Linux       | pacman -Syu --needed --noconfirm curl git clang                                   |
| Fedora           | sudo dnf update sudo dnf install clang curl git openssl-devel                     |
| OpenSUSE         | sudo zypper install clang curl git openssl-devel llvm-devel libudev-devel         |
| macOS            | brew update && brew install openssl                                               |
| Windows          | Refer to this installation guide.                                                 |

Next install Rust:

```bash
curl https://sh.rustup.rs -sSf | sh
source ~/.cargo/env
rustup default stable
rustup update
rustup update nightly
rustup target add wasm32-unknown-unknown --toolchain nightly
#test
rustc --version
rustup show

```

## Build

```bash
cargo build --release

```

## Run

```bash
./target/release/node-template --dev --tmp

```

## Visualize

Open this link to visualize the node running:
[https://polkadot.js.org/apps/?rpc=ws%3A%2F%2F127.0.0.1%3A9944#/explorer](https://polkadot.js.org/apps/?rpc=ws%3A%2F%2F127.0.0.1%3A9944#/explorer)

Note: You can use this same interface to execute transactions and other tests.