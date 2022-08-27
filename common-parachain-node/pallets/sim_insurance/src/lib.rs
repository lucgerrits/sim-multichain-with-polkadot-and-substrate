#![cfg_attr(not(feature = "std"), no_std)]

/// Pallet for Renault car manufacturer.
/// Aim: Manages the vehicles.
///
/// Custom types: DriverProfileStruct, ContractPlan
pub use pallet::*;

// #[cfg(test)]
// mod mock;

// #[cfg(test)]
// mod tests;

// Don't do benchmark for the moment
#[cfg(feature = "runtime-benchmarks")]
mod benchmarking;

// pub mod weights;
// pub use weights::WeightInfo;

#[frame_support::pallet]
pub mod pallet {
	use super::*;
	#[allow(unused_imports)]
	use frame_support::sp_std::if_std;
	use frame_support::{
		codec::{Decode, Encode},
		dispatch::DispatchResultWithPostInfo,
		inherent::Vec,
		pallet_prelude::*,
	};
	use frame_system::pallet_prelude::*;

	/// Contains the insurance plans
	#[derive(Clone, Debug, Decode, Encode, Eq, PartialEq, TypeInfo)]
	pub enum ContractPlan {
		Premium,
		Standard,
		Minimal,
	}
	/// Contains the driver profile
	#[derive(Clone, Debug, Decode, Encode, Eq, PartialEq, TypeInfo)]
	pub struct DriverProfileStruct {
		pub name: Vec<u8>,
		pub age: u8,
		pub licence_code: Vec<u8>,
		pub contract_start: i64,
		pub contract_end: i64,
		pub contract_plan: ContractPlan,
	}
	type DriverProfile = DriverProfileStruct;

	/// Configure the pallet by specifying the parameters and types on which it depends.
	#[pallet::config]
	pub trait Config: frame_system::Config {
		/// Because this pallet emits events, it depends on the runtime's definition of an event.
		type Event: From<Event<Self>> + IsType<<Self as frame_system::Config>::Event>;
		// /// Weight information for extrinsics in this pallet.
		// type WeightInfo: WeightInfo;
	}

	#[pallet::pallet]
	#[pallet::generate_store(pub(super) trait Store)]
	#[pallet::without_storage_info]
	pub struct Pallet<T>(_);

	/// List of drivers subscriptions.
	/// (
	///    driver ID => DriverProfile
	/// )
	#[pallet::storage]
	pub type Subscriptions<T: Config> =
		StorageMap<_, Blake2_128Concat, T::AccountId, DriverProfile, OptionQuery>;

	#[pallet::event]
	#[pallet::generate_deposit(pub(super) fn deposit_event)]
	pub enum Event<T: Config> {
		/// Event when a factory has been added to storage. FactoryStored(factory_id) [FactoryStored, AccountId]
		NewSignUp(T::AccountId, DriverProfile),
	}

	// Errors inform users that something went wrong.
	#[pallet::error]
	pub enum Error<T> {
		// /// Factory is already in storage
		// FactoryAlreadyStored,
	}

	#[pallet::hooks]
	impl<T: Config> Hooks<BlockNumberFor<T>> for Pallet<T> {}

	#[pallet::call]
	impl<T: Config> Pallet<T> {
		/// Create a new factory.
		/// Dispatchable that takes a singles value as a parameter (factory ID), writes the value to
		/// storage (Factories) and emits an event. This function must be dispatched by a signed extrinsic.
		#[pallet::weight(10_000 + T::DbWeight::get().writes(1))]
		pub fn sign_up(origin: OriginFor<T>, driver_profile: DriverProfile) -> DispatchResultWithPostInfo {
			let who = ensure_signed(origin)?;

			Subscriptions::<T>::insert(&who, &driver_profile);

			// Emit an event.
			Self::deposit_event(Event::NewSignUp(who, driver_profile));
			Ok(().into())
		}
	}
}
