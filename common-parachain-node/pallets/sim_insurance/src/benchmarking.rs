//! Benchmarking setup for pallet-sim-insurance

#![cfg(feature = "runtime-benchmarks")]

use super::*;

#[allow(unused)]
use crate::Pallet as SimInsurance;
use frame_benchmarking::{benchmarks, impl_benchmark_test_suite, whitelisted_caller};
use frame_system::RawOrigin;

benchmarks! {
	sign_up {
		let driver: T::AccountId = whitelisted_caller();
	}: _(RawOrigin::Signed(driver.clone()), DriverProfile {
		name: "Luc Gerrits".as_bytes().to_vec(),
		age: 26,
		licence_code: "AB 123 CD".as_bytes().to_vec(),
		contract_start: 1661668029,
		contract_end: 1693204029, //+1 year
		contract_plan: ContractPlan::Standard,
		vehicle_id: 1
	})
	verify {
		assert!(Subscriptions::<T>::contains_key(driver.clone()));
	}
}

impl_benchmark_test_suite!(SimInsurance, crate::mock::new_test_ext(), crate::mock::Test,);
