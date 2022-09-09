#![cfg_attr(not(feature = "std"), no_std)]

//! Pallet for Insurance.
//! Aim: Manages drivers insurance subscriptions.
//!
//! Custom struct: DriverProfile
//! Custom enum: ContractPlan
pub use pallet::*;

#[cfg(test)]
mod mock;

#[cfg(test)]
mod tests;

#[cfg(feature = "runtime-benchmarks")]
mod benchmarking;

pub mod weights;
pub use weights::WeightInfo;

#[frame_support::pallet]
pub mod pallet {
	use super::*;
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
	pub struct DriverProfile<AccountId> {
		pub name: Vec<u8>,
		pub age: u8,
		pub licence_code: Vec<u8>,
		pub contract_start: i64,
		pub contract_end: i64,
		pub contract_plan: ContractPlan,
		pub vehicle_id: AccountId,
	}
	
	/// Configure the pallet by specifying the parameters and types on which it depends.
	#[pallet::config]
	pub trait Config: frame_system::Config {
		/// Because this pallet emits events, it depends on the runtime's definition of an event.
		type Event: From<Event<Self>> + IsType<<Self as frame_system::Config>::Event>;
		/// Weight information for extrinsics in this pallet.
		type WeightInfo: WeightInfo;
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
		StorageMap<_, Blake2_128Concat, T::AccountId, (DriverProfile<T::AccountId>, T::BlockNumber), OptionQuery>;

	#[pallet::event]
	#[pallet::generate_deposit(pub(super) fn deposit_event)]
	pub enum Event<T: Config> {
		/// Event when a factory has been added to storage. FactoryStored(factory_id) [FactoryStored, AccountId]
		NewSignUp(T::AccountId, (DriverProfile<T::AccountId>, T::BlockNumber)),
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
		/// Dispatchable that allows to sign up and subscribe to an insurance plan.
		/// Use the DriverProfile struct to make a profile.
		/// 
		/// ```rust
		/// pub enum ContractPlan {
		/// 	Premium,
		/// 	Standard,
		/// 	Minimal,
		/// }
		/// pub struct DriverProfileStruct {
		/// 	pub name: Vec<u8>,
		/// 	pub age: u8,
		/// 	pub licence_code: Vec<u8>,
		/// 	pub contract_start: i64,
		/// 	pub contract_end: i64,
		/// 	pub contract_plan: ContractPlan,
		/// }
		/// ```
		// #[pallet::weight(10_000 + T::DbWeight::get().writes(1))]
		#[pallet::weight(T::WeightInfo::sign_up())]
		pub fn sign_up(origin: OriginFor<T>, driver_profile: DriverProfile<T::AccountId>) -> DispatchResultWithPostInfo {
			let who = ensure_signed(origin)?;

			// Get the block number from the FRAME System module.
			let current_block = <frame_system::Pallet<T>>::block_number();

			Subscriptions::<T>::insert(&who, (&driver_profile, &current_block));

			// Emit an event.
			Self::deposit_event(Event::NewSignUp(who, (driver_profile, current_block)));
			Ok(().into())
		}
	}
	impl<T: Config> Pallet<T> {
		/// Return true if driver_id is subscribed at insurance
		pub fn is_driver(driver_id: T::AccountId) -> bool {
			let status = Subscriptions::<T>::contains_key(&driver_id); //TODO: check if driver profile is currently valid
			if status == true {
				true
			} else {
				false
			}
		}
	}

	// Next is all the necessary to init the pallet with genesis info

	#[pallet::genesis_config]
	pub struct GenesisConfig<T: Config> {
		/// The `AccountId` of the sudo key.
		pub init_driver: Option<T::AccountId>,
	}

	#[cfg(feature = "std")]
	impl<T: Config> Default for GenesisConfig<T> {
		fn default() -> Self {
			Self { init_driver: None }
		}
	}

	#[pallet::genesis_build]
	impl<T: Config> GenesisBuild<T> for GenesisConfig<T> {
		fn build(&self) {
			if let Some(ref init_driver) = self.init_driver {
				Subscriptions::<T>::insert(init_driver.clone(), (DriverProfile {
					name: "Luc Gerrits".as_bytes().to_vec(),
					age: 26,
					contract_start: 2022,
					contract_end: 2025,
					licence_code: "AB 123 CD".as_bytes().to_vec(),
					contract_plan: ContractPlan::Standard,
					vehicle_id: init_driver.clone()
				}, <frame_system::Pallet<T>>::block_number()));
			}
		}
	}
}
