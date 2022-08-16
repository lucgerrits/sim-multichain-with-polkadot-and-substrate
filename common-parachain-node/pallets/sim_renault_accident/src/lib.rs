#![cfg_attr(not(feature = "std"), no_std)]

/// Pallet to report an accident at Renault.
/// Aim: report an accident at Renault by sending a data hash. The raw data should be stored elsewhere.
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
	use frame_support::{dispatch::DispatchResultWithPostInfo, pallet_prelude::*, BoundedVec};
	use frame_system::pallet_prelude::*;

	/// Configure the pallet by specifying the parameters and types on which it depends.
	#[pallet::config]
	pub trait Config: frame_system::Config {
		/// Because this pallet emits events, it depends on the runtime's definition of an event.
		type Event: From<Event<Self>> + IsType<<Self as frame_system::Config>::Event>;
		// /// Weight information for extrinsics in this pallet.
		// type WeightInfo: WeightInfo;

		type HashLimit: Get<u32>;
	}

	#[pallet::pallet]
	#[pallet::generate_store(pub(super) trait Store)]
	// #[pallet::without_storage_info]
	pub struct Pallet<T>(_);

	/// List of accidents.
	/// (
	///    vehicle ID => data_hash
	/// )
	#[pallet::storage]
	pub type Accidents<T: Config> =
		StorageMap<_, Blake2_128Concat, T::AccountId, BoundedVec<u8, T::HashLimit>, OptionQuery>;

		
	#[pallet::event]
	#[pallet::generate_deposit(pub(super) fn deposit_event)]
	pub enum Event<T: Config> {
		/// Event when a factory has been added to storage. FactoryStored(factory_id) [FactoryStored, AccountId]
		AccidentStored(T::AccountId, BoundedVec<u8, T::HashLimit>),
	}

	// Errors inform users that something went wrong.
	#[pallet::error]
	pub enum Error<T> {
		/// Vehicle is not in storage.
		UnknownVehicle,
		/// Vehicle is already in storage
		AccidentAlreadyStored,
		/// Vehicle ID and origin aren't match
		VehicleNotMatchingOrigin,
	}

	#[pallet::hooks]
	impl<T: Config> Hooks<BlockNumberFor<T>> for Pallet<T> {}

	#[pallet::call]
	impl<T: Config> Pallet<T> {
		/// Report an accident.
		/// Dispatchable that...
		#[pallet::weight(10_000 + T::DbWeight::get().writes(1))]
		pub fn report_accident(
			origin: OriginFor<T>,
			vehicle_id: T::AccountId,
			data_hash: BoundedVec<u8, T::HashLimit>,
		) -> DispatchResultWithPostInfo {
			ensure_root(origin)?;

			// Verify that the specified data_hash has not already been stored.
			ensure!(!Accidents::<T>::contains_key(&vehicle_id), Error::<T>::AccidentAlreadyStored);

			// Store the factory_id with the sender and block number.
			Accidents::<T>::insert(&vehicle_id, &data_hash);

			// Emit an event.
			Self::deposit_event(Event::AccidentStored(vehicle_id, data_hash));
			Ok(().into())
		}
	}
}
