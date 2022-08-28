use super::*;
#[allow(unused_imports)]
use crate::{mock::*, Error, Event as TestEvent};
#[allow(unused_imports)]
use frame_support::{assert_noop, assert_ok};
#[allow(unused_imports)]
use sp_runtime::DispatchError;

#[test]
fn it_works_for_default_value() {
	new_test_ext().execute_with(|| {
		// create a new factory
		assert_ok!(SimInsurancePallet::sign_up(
			Origin::signed(1),
			DriverProfileStruct {
				name: "Luc Gerrits".as_bytes().to_vec(),
				age: 26,
				licence_code: "AB 123 CD".as_bytes().to_vec(),
				contract_start: 1661668029,
				contract_end: 1693204029, //+1 year
				contract_plan: ContractPlan::Standard
			}
		));
		// is factory stored
		assert!(Subscriptions::<Test>::contains_key(1));
	});
}
