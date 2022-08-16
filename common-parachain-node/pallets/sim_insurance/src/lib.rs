#![cfg_attr(not(feature = "std"), no_std)]

/// Pallet for Renault car manufacturer.
/// Aim: Manages the vehicles.
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
	use frame_support::{dispatch::DispatchResultWithPostInfo, pallet_prelude::*};
	use frame_system::pallet_prelude::*;

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

	/// List of factory IDs added by the admin (sudo).
	/// (
	///    actory ID => block nb
	/// )
	#[pallet::storage]
	pub type Factories<T: Config> =
		StorageMap<_, Blake2_128Concat, T::AccountId, T::BlockNumber, OptionQuery>;

	/// List of vehicle ID added by the factories.
	/// (
	///    vehicle ID => (factory ID, block nb)
	/// )
	#[pallet::storage]
	pub type Vehicles<T: Config> =
		StorageMap<_, Blake2_128Concat, T::AccountId, (T::AccountId, T::BlockNumber), OptionQuery>;

	/// List of vehicle ID status.
	/// (
	///    vehicle ID => is_initialized
	/// )
	#[pallet::storage]
	pub type VehiclesStatus<T: Config> =
		StorageMap<_, Blake2_128Concat, T::AccountId, bool, OptionQuery>;

	#[pallet::event]
	#[pallet::generate_deposit(pub(super) fn deposit_event)]
	pub enum Event<T: Config> {
		/// Event when a factory has been added to storage. FactoryStored(factory_id) [FactoryStored, AccountId]
		FactoryStored(T::AccountId),
		/// Event when a vehicle has been added to storage by a factory. VehicleStored(vehicle_id, origin) [VehicleStored, AccountId, AccountId]
		VehicleStored(T::AccountId, T::AccountId),
		/// Vehicle is now initialized.  VehicleInitialized(vehicle_id) [CrashStored, AccountId]
		VehicleInitialized(T::AccountId),
	}

	// Errors inform users that something went wrong.
	#[pallet::error]
	pub enum Error<T> {
		/// Factory is already in storage
		FactoryAlreadyStored,
		/// Factory is not in storage.
		UnknownFactory,
		/// Vehicle is not in storage.
		UnknownVehicle,
		/// Vehicle is already in storage
		VehicleAlreadyStored,
		/// Vehicle and origin aren't match
		VehicleNotMatchingOrigin,
	}

	#[pallet::hooks]
	impl<T: Config> Hooks<BlockNumberFor<T>> for Pallet<T> {}

	#[pallet::call]
	impl<T: Config> Pallet<T> {
		/// Create a new factory.
		/// Dispatchable that takes a singles value as a parameter (factory ID), writes the value to
		/// storage (Factories) and emits an event. This function must be dispatched by a signed extrinsic.
		#[pallet::weight(10_000 + T::DbWeight::get().writes(1))]
		pub fn create_factory(
			origin: OriginFor<T>,
			factory_id: T::AccountId,
		) -> DispatchResultWithPostInfo {
			ensure_root(origin)?;

			// Verify that the specified factory_id has not already been stored.
			ensure!(!Factories::<T>::contains_key(&factory_id), Error::<T>::FactoryAlreadyStored);

			// Get the block number from the FRAME System module.
			let current_block = <frame_system::Pallet<T>>::block_number();

			// Store the factory_id with the sender and block number.
			Factories::<T>::insert(&factory_id, current_block);

			// Emit an event.
			Self::deposit_event(Event::FactoryStored(factory_id));
			Ok(().into())
		}

		/// Create a new vehicle.
		/// Dispatchable that takes a singles value as a parameter (vehicle ID), writes the value to
		/// storage (Vehicles) and emits an event. This function must be dispatched by a signed extrinsic.
		#[pallet::weight(10_000 + T::DbWeight::get().writes(1))]
		pub fn create_vehicle(
			origin: OriginFor<T>,
			vehicle_id: T::AccountId,
		) -> DispatchResultWithPostInfo {
			let who = ensure_signed(origin)?;

			// Verify that the specified factory_id exists.
			ensure!(Factories::<T>::contains_key(&who), Error::<T>::UnknownFactory);

			// Verify that the specified car_id has not already been stored.
			ensure!(!Vehicles::<T>::contains_key(&vehicle_id), Error::<T>::VehicleAlreadyStored);

			// Get the block number from the FRAME System module.
			let current_block = <frame_system::Pallet<T>>::block_number();

			// Store the factory_id with the sender and block number.
			Vehicles::<T>::insert(&vehicle_id, (&who, current_block));

			// Emit an event.
			Self::deposit_event(Event::VehicleStored(vehicle_id, who));
			Ok(().into())
		}

		/// Init a vehicle.
		/// Dispatchable that takes a singles value as a parameter (vehicle ID), writes the value to
		/// storage (Factories) and emits an event. This function must be dispatched by a signed extrinsic.
		#[pallet::weight(10_000 + T::DbWeight::get().writes(1))]
		pub fn init_vehicle(
			origin: OriginFor<T>,
			vehicle_id: T::AccountId,
		) -> DispatchResultWithPostInfo {
			let who = ensure_signed(origin)?;

			// Verify that the origin vehicle exists.
			ensure!(Vehicles::<T>::contains_key(&who), Error::<T>::UnknownVehicle);

			// Verify that the specified vehicle_id matches the origin.
			ensure!(who == vehicle_id, Error::<T>::VehicleNotMatchingOrigin);

			// Set the vehicle as initialized.
			VehiclesStatus::<T>::insert(&vehicle_id, true);

			// Emit an event.
			Self::deposit_event(Event::VehicleInitialized(vehicle_id));
			Ok(().into())
		}
	}
}
