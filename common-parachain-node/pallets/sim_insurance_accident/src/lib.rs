#![cfg_attr(not(feature = "std"), no_std)]

//! Pallet to report an accident at Insurance.
//! Aim: report an accident at Insurance.
//! NOTE: This pallet is tightly coupled with pallet-sim-insurance.
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
	// use cumulus_pallet_xcm::Config;
	use cumulus_pallet_xcm::{ensure_sibling_para, Origin as CumulusOrigin};
	use cumulus_primitives_core::ParaId;
	#[allow(unused_imports)]
	use frame_support::{
		dispatch::{DispatchError, DispatchResult},
		inherent::Vec,
		pallet_prelude::*,
		sp_std::if_std,
	};
	use frame_system::{pallet_prelude::*, Config as SystemConfig};
	use log;
	use sha2::{Digest, Sha256};
	use sp_std::prelude::*;
	use xcm::latest::prelude::*;

	/// Configure the pallet by specifying the parameters and types on which it depends.
	#[pallet::config]
	pub trait Config: frame_system::Config + pallet_sim_insurance::Config
	//+ pallet_sim_renault_accident::pallet::Config
	{
		/// Because this pallet emits events, it depends on the runtime's definition of an event.
		type Event: From<Event<Self>> + IsType<<Self as frame_system::Config>::Event>;
		// /// Weight information for extrinsics in this pallet.
		// type WeightInfo: WeightInfo;

		type Origin: From<<Self as SystemConfig>::Origin>
			+ Into<Result<CumulusOrigin, <Self as Config>::Origin>>;
		type XcmSender: SendXcm;
	}

	#[pallet::pallet]
	#[pallet::generate_store(pub(super) trait Store)]
	// #[pallet::without_storage_info]
	pub struct Pallet<T>(_);

	/// List of accidents.
	/// Accident ID = Hash(driver ID + AccidentCount(driver ID) )
	/// (
	///    Accident ID => (vehicle ID, vehicle_accident_count)
	/// )
	#[pallet::storage]
	pub type Accidents<T: Config> =
		StorageMap<_, Blake2_128Concat, [u8; 32], (T::AccountId, u32), OptionQuery>;

	/// List of accident count.
	/// (
	///    driver ID => driver_accident_count
	/// )
	#[pallet::storage]
	pub type AccidentCount<T: Config> =
		StorageMap<_, Blake2_128Concat, T::AccountId, u32, OptionQuery>;

	#[pallet::event]
	#[pallet::generate_deposit(pub(super) fn deposit_event)]
	pub enum Event<T: Config> {
		/// Event when a accident has been added to storage. AccidentStored(driver_id, count, vehicle_id, vehicle_accident_count) [AccidentStored, AccountId, u32, AccountId, u32]
		AccidentStored(T::AccountId, u32, T::AccountId, u32),
		/// Event when sent a vehicle data request from other chain.
		RequestData(ParaId, T::AccountId, u32),
		/// Error event when sent a vehicle data request from other chain.
		ErrorRequestData(ParaId, SendError),
		/// Event when received vehicle data from other chain.
		ReceiveData(ParaId, [u8; 32]),
	}

	// Errors inform users that something went wrong.
	#[pallet::error]
	pub enum Error<T> {
		/// Driver is not in storage.
		UnknownDriver,
		/// Driver is already in storage
		AccidentAlreadyStored,
		/// Driver ID and origin aren't match
		DriverNotMatchingOrigin,
		/// Error sending an Xcm
		ErrorSendXcm
	}

	#[pallet::hooks]
	impl<T: Config> Hooks<BlockNumberFor<T>> for Pallet<T> {}

	#[allow(unused_variables)]
	#[pallet::call]
	impl<T: Config> Pallet<T> {
		/// Report an accident to the insurance.
		/// Dispatchable that allows to report an accident, it will automatically request Renault for vehicle data with the given vehicle accident count.
		///
		#[pallet::weight(10_000 + T::DbWeight::get().writes(1))]
		// #[pallet::weight(<T as pallet::Config>::WeightInfo::report_accident())]
		pub fn report_accident(
			origin: OriginFor<T>,
			vehicle_id: T::AccountId,
			vehicle_accident_count: u32,
		) -> DispatchResult {
			// if_std! {
			// 	println!("{:02x?}", data_hash);
			// }
			let driver_id = ensure_signed(origin)?;

			//check if vehicle exists in pallet sim_renault
			ensure!(
				pallet_sim_insurance::Pallet::<T>::is_driver(driver_id.clone()),
				Error::<T>::UnknownDriver
			);

			//check if vehicle_id matches the driver subscribed vehicle_id
			//TODO

			//get vehicle accident count
			// let count: u32 = AccidentCount::get(&vehicle_id)?;
			let count: u32 = match <AccidentCount<T>>::get(&driver_id) {
				// Return an error if the value has not been set.
				None => 0,
				Some(val) => val,
			};

			//create key from vehicle_id and count
			let mut parts = Vec::new();
			parts.push(driver_id.encode());
			parts.push(count.to_le_bytes().to_vec());
			let accident_key: [u8; 32] = Self::create_composite_key(parts);

			// Verify that the specified data_hash has not already been stored.
			ensure!(
				!Accidents::<T>::contains_key(&accident_key),
				Error::<T>::AccidentAlreadyStored
			);

			// Store the data_hash.
			Accidents::<T>::insert(&accident_key, (&vehicle_id, &vehicle_accident_count));
			// if_std! {
			// 	println!("{:02x?}", accident_key);
			// }

			//inc vehicle accident count
			let next_count = count + 1;
			AccidentCount::<T>::insert(&vehicle_id, next_count);

			// Emit an event.
			Self::deposit_event(Event::AccidentStored(
				driver_id.clone(),
				count.clone(),
				vehicle_id.clone(),
				vehicle_accident_count.clone(),
			));

			// Use XCM to check if vehicle exists at Renault and retrieve the data hash
			let para: ParaId = ParaId::from(2000);

			// Buold call used by Xcm transact
			let call = pallet_sim_renault_accident::ParaChainCall::<T>::PalletSimRenaultAccident(
				pallet_sim_renault_accident::PalletSimRenaultAccidentCall::RequestData(
					vehicle_id.clone(),
					vehicle_accident_count.clone(),
				),
			);

			// Send the XCM call
			match <T as pallet::Config>::XcmSender::send_xcm(
				(1, Junction::Parachain(para.into())),
				Xcm(vec![Transact {
					origin_type: OriginKind::Native,
					require_weight_at_most: 1_000,
					call: call.encode().into(),
				}]),
			) {
				Ok(result) => {
					Self::deposit_event(Event::RequestData(
						para,
						vehicle_id,
						vehicle_accident_count,
					));
					Ok(())
				},
				Err(e) => {
					log::info!("Send XCM error (sim_insurance_accident):\n {:?} \n\n", e);
					Self::deposit_event(Event::ErrorRequestData(
						para,
						e.clone().try_into().unwrap_or(e),
					));
					Err(DispatchError::Other("ErrorRequestData"))
				},
			}
		}

		/// XCM receive data.
		/// Dispatchable that...
		#[pallet::weight(0)]
		pub fn receive_data(origin: OriginFor<T>, data: [u8; 32]) -> DispatchResult {
			// Only accept pings from other chains.
			let orgin_para = ensure_sibling_para(<T as Config>::Origin::from(origin))?;

			Self::deposit_event(Event::ReceiveData(orgin_para.clone(), data.clone()));
			Ok(())
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

	/// Module representing pallet sim_renault_accident.
	/// This is used to avoid importing the entire pallet or runtime
	mod pallet_sim_renault_accident {
		use crate::*;
		use codec::{Decode, Encode};
		use frame_support::RuntimeDebug;

		/// The encoded index correspondes to sim_renault_accident pallet configuration.
		/// Ex: RequestData is the second pallet call
		#[derive(Encode, Decode, RuntimeDebug)]
		pub enum PalletSimRenaultAccidentCall<T: Config> {
			#[codec(index = 1)]
			RequestData(T::AccountId, u32),
		}

		/// The encoded index correspondes to Renault's Runtime module configuration.
		/// Ex: PalletSimRenaultAccident is fixed to the index 101. See the node construct_runtime! macro to view all indexes.
		#[derive(Encode, Decode, RuntimeDebug)]
		pub enum ParaChainCall<T: Config> {
			#[codec(index = 101)]
			PalletSimRenaultAccident(PalletSimRenaultAccidentCall<T>),
		}
	}
}
