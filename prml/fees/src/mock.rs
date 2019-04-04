// Copyright 2019 Parity Technologies (UK) Ltd.
// This file is part of Substrate.

// Substrate is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// Substrate is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with Substrate.  If not, see <http://www.gnu.org/licenses/>.

//! Test utilities

#![cfg(test)]

use crate::{system, BuyFeeAsset, GenesisConfig, Module, OnFeeCharged, Trait};
use cennznet_primitives::{Balance, FeeExchange};
use primitives::{Blake2Hasher, H256};
use rstd::marker::PhantomData;
use runtime_io;
use runtime_primitives::BuildStorage;
use runtime_primitives::{
	testing::{Digest, DigestItem, Header},
	traits::{BlakeTwo256, IdentityLookup},
};
use support::{
	decl_module, decl_storage,
	dispatch::Result,
	impl_outer_event, impl_outer_origin,
	traits::{ArithmeticType, TransferAsset, WithdrawReason},
	StorageValue,
};

impl_outer_origin! {
	pub enum Origin for Test {}
}

mod fees {
	pub use crate::{Call, Event};
}

impl_outer_event! {
	pub enum TestEvent for Test {
		fees<T>,
	}
}

pub struct TransferAssetMock;

impl<AccountId> TransferAsset<AccountId> for TransferAssetMock {
	type Amount = u64;

	fn transfer(_: &AccountId, _: &AccountId, _: Self::Amount) -> Result {
		Ok(())
	}
	fn withdraw(_: &AccountId, _: Self::Amount, _: WithdrawReason) -> Result {
		Ok(())
	}
	fn deposit(_: &AccountId, _: Self::Amount) -> Result {
		Ok(())
	}
}

impl ArithmeticType for TransferAssetMock {
	type Type = u64;
}

// Workaround for https://github.com/rust-lang/rust/issues/26925 . Remove when sorted.
#[derive(Clone, PartialEq, Eq, Debug)]
pub struct Test;
impl system::Trait for Test {
	type Origin = Origin;
	type Index = u64;
	type BlockNumber = u64;
	type Hash = H256;
	type Hashing = BlakeTwo256;
	type Digest = Digest;
	type AccountId = u64;
	type Lookup = IdentityLookup<u64>;
	type Header = Header;
	type Event = TestEvent;
	type Log = DigestItem;
}

pub trait OnFeeChargedMockTrait: system::Trait {}

decl_module! {
	pub struct OnFeeChargedMockModule<T: OnFeeChargedMockTrait> for enum Call where origin: T::Origin {
		pub fn do_nothing() -> Result { Ok(()) }
	}
}

decl_storage! {
	trait Store for OnFeeChargedMockModule<T: OnFeeChargedMockTrait> as F {
		Amount get(amount): u64;
	}
}

impl<T: OnFeeChargedMockTrait> OnFeeCharged<u64> for OnFeeChargedMockModule<T> {
	fn on_fee_charged(fee: &u64) {
		<Amount<T>>::put(fee);
	}
}

impl OnFeeChargedMockTrait for Test {}

impl Trait for Test {
	type Call = Call<Self>;
	type Event = TestEvent;
	type TransferAsset = TransferAssetMock;
	type OnFeeCharged = OnFeeChargedMock;
	type BuyFeeAsset = BuyFeeAssetMock<Test>;
}

pub type System = system::Module<Test>;
pub type Fees = Module<Test>;
pub type OnFeeChargedMock = OnFeeChargedMockModule<Test>;

pub struct ExtBuilder {
	transaction_base_fee: u64,
	transaction_byte_fee: u64,
}
impl Default for ExtBuilder {
	fn default() -> Self {
		Self {
			transaction_base_fee: 0,
			transaction_byte_fee: 0,
		}
	}
}
impl ExtBuilder {
	pub fn transaction_base_fee(mut self, transaction_base_fee: u64) -> Self {
		self.transaction_base_fee = transaction_base_fee;
		self
	}
	pub fn transaction_byte_fee(mut self, transaction_byte_fee: u64) -> Self {
		self.transaction_byte_fee = transaction_byte_fee;
		self
	}
	pub fn build(self) -> runtime_io::TestExternalities<Blake2Hasher> {
		let mut t = system::GenesisConfig::<Test>::default().build_storage().unwrap().0;
		t.extend(
			GenesisConfig::<Test> {
				transaction_base_fee: self.transaction_base_fee,
				transaction_byte_fee: self.transaction_byte_fee,
			}
			.build_storage()
			.unwrap()
			.0,
		);
		t.into()
	}
}

// A NOOP BuyFeeAsset implementor
pub struct BuyFeeAssetMock<T: Trait>(PhantomData<T>);

impl<T: Trait> BuyFeeAsset<T::AccountId, Balance> for BuyFeeAssetMock<T> {
	fn buy_fee_asset(_who: &T::AccountId, _amount: Balance, _fee_exchange: &FeeExchange<Balance>) -> Result {
		Ok(())
	}
}