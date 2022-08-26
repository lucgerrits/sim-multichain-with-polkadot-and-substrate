use super::*;
#[allow(unused_imports)]
use crate::{mock::*, Error, Event as TestEvent};
#[allow(unused_imports)]
use frame_support::{assert_noop, assert_ok, inherent::Vec, traits::IsType};
#[allow(unused_imports)]
use sha2::{digest::Update, Digest, Sha256};
#[allow(unused_imports)]
use sp_runtime::DispatchError;
use sp_std::if_std;

#[test]
fn it_works_for_default_value() {
	new_test_ext().execute_with(|| {
		let vehicle: u64 = 1;

		let mut hasher = Sha256::new();
		sha2::Digest::update(&mut hasher, "Hello World".as_bytes());
		let data_hash = hasher.finalize().into();

		// create a new accident
		assert_ok!(SimRenaultAccidentPallet::report_accident(
			Origin::signed(vehicle),
			vehicle,
			data_hash
		));

		// is accident stored
		assert!(AccidentCount::<Test>::contains_key(vehicle));

		let count: u32 = match AccidentCount::<Test>::get(vehicle) {
			// Return an error if the value has not been set.
			None => 0,
			Some(val) => val,
		};
		if_std! {
			println!("Accident Count={}", count);
		}
		let mut hasher = Sha256::new();
		sha2::Digest::update(&mut hasher, vehicle.to_ne_bytes());
		sha2::Digest::update(&mut hasher, (count - 1).to_ne_bytes()); //-1 because we start at 0
		let accident_key: [u8; 32] = hasher.finalize().into();
		if_std! {
			println!("{:02x?}", accident_key);
		}
		assert!(Accidents::<Test>::contains_key(accident_key));
	});
}
