# Some useful info to debug and code a pallet

Run debug or a test of a pallet:
```bash
SKIP_WASM_BUILD=1 RUST_LOG=runtime=debug cargo test --package <INSERT_PALLET_NAME> -- --nocapture
//example:
SKIP_WASM_BUILD=1 RUST_LOG=runtime=debug cargo test --package pallet-sim-renault -- --nocapture
```


Run benchmark of a pallet:
```bash
cargo build --release --features runtime-benchmarks

./target/release/parachain-collator benchmark pallet --chain dev --pallet "pallet_sim_renault" --extrinsic "*" --repeat 1000 --output benchmark_sim_renault.rs
#or
cargo build --release --features runtime-benchmarks && ./target/release/parachain-collator benchmark pallet --chain=dev --pallet="pallet_sim_insurance" --extrinsic="*" --wasm-execution=compiled --execution=wasm --repeat=20 --steps=50 --template=./frame-weight-template.hbs --output=./pallets/sim_insurance/src/weights.rs
```

>More about benchmarking in this video: https://www.youtube.com/watch?v=Qa6sTyUqgek

## Links

- https://github.com/paritytech/substrate/blob/master/frame/benchmarking/README.md
- https://docs.substrate.io/reference/how-to-guides/weights/add-benchmarks/
- https://docs.substrate.io/reference/how-to-guides/weights/use-custom-weights/
- https://crates.parity.io/frame_benchmarking/index.html