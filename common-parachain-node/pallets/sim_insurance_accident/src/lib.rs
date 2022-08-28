#![cfg_attr(not(feature = "std"), no_std)]

/// Pallet to report an accident at Insurance.
/// Aim: report an accident at Insurance.
/// NOTE: This pallet is tightly coupled with pallet-sim-insurance.
pub use pallet::*;

// #[cfg(test)]
// mod mock;

// #[cfg(test)]
// mod tests;

// #[cfg(feature = "runtime-benchmarks")]
// mod benchmarking;

// pub mod weights;
// pub use weights::WeightInfo;

#[frame_support::pallet]
pub mod pallet {
	use super::*;
	#[allow(unused_imports)]
	use frame_support::sp_std::if_std;
	#[allow(unused_imports)]
	use frame_support::{dispatch::DispatchResultWithPostInfo, fail, inherent::Vec, pallet_prelude::*};
	use frame_system::pallet_prelude::*;
	use sha2::{Digest, Sha256};
	
	/// Configure the pallet by specifying the parameters and types on which it depends.
	#[pallet::config]
	pub trait Config: frame_system::Config + pallet_sim_insurance::Config {
		/// Because this pallet emits events, it depends on the runtime's definition of an event.
		type Event: From<Event<Self>> + IsType<<Self as frame_system::Config>::Event>;
		// /// Weight information for extrinsics in this pallet.
		// type WeightInfo: WeightInfo;
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
		StorageMap<_, Blake2_128Concat, [u8; 32], [u8; 32], OptionQuery>;

	/// List of accident count.
	/// (
	///    vehicle ID => accident_count
	/// )
	#[pallet::storage]
	pub type AccidentCount<T: Config> =
		StorageMap<_, Blake2_128Concat, T::AccountId, u32, OptionQuery>;

	#[pallet::event]
	#[pallet::generate_deposit(pub(super) fn deposit_event)]
	pub enum Event<T: Config> {
		/// Event when a accident has been added to storage. AccidentStored(vehicle_id, count, data_hash) [AccidentStored, AccountId, u32, [u8; 32]]
		AccidentStored(T::AccountId, u32, [u8; 32]),
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

	#[allow(unused_variables)]
	#[pallet::call]
	impl<T: Config> Pallet<T> {
		/// Report an accident.
		/// Dispatchable that...
		#[pallet::weight(10_000 + T::DbWeight::get().writes(1))]
		// #[pallet::weight(<T as pallet::Config>::WeightInfo::report_accident())]
		pub fn report_accident(
			origin: OriginFor<T>,
			// vehicle_id: T::AccountId,
			data_hash: [u8; 32],
		) -> DispatchResultWithPostInfo {
			// if_std! {
			// 	println!("{:02x?}", data_hash);
			// }
			let vehicle_id = ensure_signed(origin)?;

			// //check if vehicle exists in pallet sim_renault
			// if pallet_sim_renault::Pallet::<T>::is_vehicle(vehicle_id.clone()) {
			// 	fail!(Error::<T>::AccidentAlreadyStored);
			// }

			//get vehicle accident count
			// let count: u32 = AccidentCount::get(&vehicle_id)?;
			let count: u32 = match <AccidentCount<T>>::get(&vehicle_id) {
				// Return an error if the value has not been set.
				None => 0,
				Some(val) => val,
			};

			//create key from vehicle_id and count
			let mut parts = Vec::new();
			parts.push(vehicle_id.encode());
			parts.push(count.to_le_bytes().to_vec());
			let accident_key: [u8; 32] = Self::create_composite_key(parts);

			// Verify that the specified data_hash has not already been stored.
			ensure!(!Accidents::<T>::contains_key(&accident_key), Error::<T>::AccidentAlreadyStored);

			// Store the data_hash.
			Accidents::<T>::insert(&accident_key, &data_hash);
			// if_std! {
			// 	println!("{:02x?}", accident_key);
			// }

			//inc vehicle accident count
			let next_count = count + 1;
			AccidentCount::<T>::insert(&vehicle_id,  next_count);

			// Emit an event.
			Self::deposit_event(Event::AccidentStored(vehicle_id, count, data_hash));
			Ok(().into())
		}
	}

	impl<T: Config> Pallet<T> {
		pub fn create_composite_key(parts: Vec<Vec<u8>>) -> [u8; 32] {
			let concatenated = parts.iter().fold(Vec::new(), |mut res: Vec<u8>, new| {
				res.extend(new.as_slice());
				res
			});
			let mut hasher = Sha256::new();
			Digest::update(&mut hasher, concatenated.as_slice());
			hasher.finalize().into()
		}
	}
}
