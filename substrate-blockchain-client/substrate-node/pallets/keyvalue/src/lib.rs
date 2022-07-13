#![cfg_attr(not(feature = "std"), no_std)]

/// Edit this file to define custom logic or remove it if it is not needed.
/// Learn more about FRAME and the core library of Substrate FRAME pallets:
/// <https://docs.substrate.io/v3/runtime/frame>
pub use pallet::*;

#[frame_support::pallet]
pub mod pallet {
	use frame_support::{dispatch::DispatchResult, pallet_prelude::*};
	use frame_system::pallet_prelude::*;
	use sp_std::vec::Vec;

	/// Configure the pallet by specifying the parameters and types on which it depends.
	#[pallet::config]
	pub trait Config: frame_system::Config {
		/// Because this pallet emits events, it depends on the runtime's definition of an event.
		type Event: From<Event<Self>> + IsType<<Self as frame_system::Config>::Event>;
	}

	#[pallet::pallet]
	#[pallet::generate_store(pub(super) trait Store)]
	pub struct Pallet<T>(_);

	// The pallet's runtime storage items.
	// https://docs.substrate.io/v3/runtime/storage
	#[pallet::storage]
	// Learn more about declaring storage items:
	// https://docs.substrate.io/v3/runtime/storage#declaring-storage-items
	pub type KeyValue<T> = StorageMap<_, Blake2_128Concat, Vec<u8>, Vec<u8>>;//key: Vec<u8>, value: Vec<u8>

	// Pallets use events to inform users when important changes are made.
	// https://docs.substrate.io/v3/runtime/events-and-errors
	#[pallet::event]
	#[pallet::generate_deposit(pub(super) fn deposit_event)]
	pub enum Event<T: Config> {
		/// New insert in storage
		/// parameters. [who, key, value]
		KeyValueStored(T::AccountId, Vec<u8>, Vec<u8>),
		/// New update in storage
		/// parameters. [who, key, oldvalue, newvalue]
		KeyValueUpdated(T::AccountId, Vec<u8>, Vec<u8>, Vec<u8>),
	}

	// Errors inform users that key went wrong.
	#[pallet::error]
	pub enum Error<T> {
		/// Error names should be descriptive.
		NoneValue,
	}

	// Dispatchable functions allows users to interact with the pallet and invoke state changes.
	// These functions materialize as "extrinsics", which are often compared to transactions.
	// Dispatchable functions must be annotated with a weight and must return a DispatchResult.
	#[pallet::call]
	impl<T: Config> Pallet<T> {
		/// An example dispatchable that takes a singles value as a parameter, writes the value to
		/// storage and emits an event. This function must be dispatched by a signed extrinsic.
		#[pallet::weight((
			0,
			DispatchClass::Normal,
			Pays::No
		))]
		pub fn store(origin: OriginFor<T>, key: Vec<u8>, value: Vec<u8>) -> DispatchResult {
			// Check that the extrinsic was signed and get the signer.
			// This function will return an error if the extrinsic is not signed.
			// https://docs.substrate.io/v3/runtime/origins
			let who = ensure_signed(origin)?;

			if <KeyValue<T>>::contains_key(key.clone()) {
				// get storage.
				let oldvalue: Vec<u8> = match <KeyValue<T>>::get(key.clone()) {
					Some(value) => value.clone(),
					None => Err(Error::<T>::NoneValue)?
				};

				// remove old value from storage.
				<KeyValue<T>>::remove(key.clone());
				
				// Update storage with new value.
				<KeyValue<T>>::insert(key.clone(), value.clone());

				// Emit an event.
				Self::deposit_event(Event::KeyValueUpdated(who, key.clone(), oldvalue.clone(), value.clone()));
			} else {
				// Update storage.
				<KeyValue<T>>::insert(key.clone(), value.clone());

				// Emit an event.
				Self::deposit_event(Event::KeyValueStored(who, key.clone(), value.clone()));
			}

			// Return a successful DispatchResultWithPostInfo
			Ok(())
		}
	}
}
