// This file is part of Substrate.

// Copyright (C) 2022 Parity Technologies (UK) Ltd.
// SPDX-License-Identifier: Apache-2.0

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
// http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

//! Autogenerated weights for pallet_sim_renault_accident
//!
//! THIS FILE WAS AUTO-GENERATED USING THE SUBSTRATE BENCHMARK CLI VERSION 4.0.0-dev
//! DATE: 2022-08-28, STEPS: `50`, REPEAT: 20, LOW RANGE: `[]`, HIGH RANGE: `[]`
//! HOSTNAME: ``, CPU: ``
//! EXECUTION: Some(Wasm), WASM-EXECUTION: Compiled, CHAIN: Some("dev"), DB CACHE: 1024

// Executed Command:
// ./target/release/parachain-collator
// benchmark
// pallet
// --chain=dev
// --pallet=pallet_sim_renault_accident
// --extrinsic=*
// --wasm-execution=compiled
// --execution=wasm
// --repeat=20
// --steps=50
// --template=./frame-weight-template.hbs
// --output=./pallets/sim_renault_accident/src/weights.rs

#![cfg_attr(rustfmt, rustfmt_skip)]
#![allow(unused_parens)]
#![allow(unused_imports)]

use frame_support::{traits::Get, weights::{Weight, constants::RocksDbWeight}};
use sp_std::marker::PhantomData;

/// Weight functions needed for pallet_sim_renault_accident.
pub trait WeightInfo {
	fn report_accident() -> Weight;
}

/// Weights for pallet_sim_renault_accident using the Substrate node and recommended hardware.
pub struct SubstrateWeight<T>(PhantomData<T>);
impl<T: frame_system::Config> WeightInfo for SubstrateWeight<T> {
	// Storage: SimRenaultPallet VehiclesStatus (r:1 w:0)
	// Storage: SimRenaultAccidentPallet AccidentCount (r:1 w:1)
	// Storage: SimRenaultAccidentPallet Accidents (r:1 w:1)
	fn report_accident() -> Weight {
		(25_682_000 as Weight)
			.saturating_add(T::DbWeight::get().reads(3 as Weight))
			.saturating_add(T::DbWeight::get().writes(2 as Weight))
	}
}

// For backwards compatibility and tests
impl WeightInfo for () {
	// Storage: SimRenaultPallet VehiclesStatus (r:1 w:0)
	// Storage: SimRenaultAccidentPallet AccidentCount (r:1 w:1)
	// Storage: SimRenaultAccidentPallet Accidents (r:1 w:1)
	fn report_accident() -> Weight {
		(25_682_000 as Weight)
			.saturating_add(RocksDbWeight::get().reads(3 as Weight))
			.saturating_add(RocksDbWeight::get().writes(2 as Weight))
	}
}