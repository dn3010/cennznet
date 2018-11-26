//! The CENNZNET runtime. This can be compiled with `#[no_std]`, ready for Wasm.

// This file is mostly copied from https://github.com/paritytech/substrate/blob/a786c1d22ef141f2ffd317bf424b3e7319d62246/node/runtime/src/lib.rs#L17

#![cfg_attr(not(feature = "std"), no_std)]
// `construct_runtime!` does a lot of recursion and requires us to increase the limit to 256.
#![recursion_limit="256"]

#[macro_use]
extern crate srml_support;

#[macro_use]
extern crate sr_primitives as runtime_primitives;

#[cfg(feature = "std")]
#[macro_use]
extern crate serde_derive;

extern crate substrate_primitives;

#[macro_use]
extern crate substrate_client as client;

#[macro_use]
extern crate parity_codec_derive;

extern crate parity_codec as codec;

extern crate sr_std as rstd;
extern crate srml_balances as balances;
extern crate srml_consensus as consensus;
extern crate srml_contract as contract;
extern crate srml_council as council;
extern crate srml_democracy as democracy;
extern crate srml_executive as executive;
extern crate srml_session as session;
extern crate srml_staking as staking;
extern crate srml_system as system;
extern crate srml_timestamp as timestamp;
extern crate srml_treasury as treasury;
extern crate srml_upgrade_key as upgrade_key;
#[macro_use]
extern crate sr_version as version;
extern crate cennznet_primitives;
extern crate substrate_finality_grandpa_primitives;

#[cfg(feature = "std")]
use codec::{Encode, Decode};
use rstd::prelude::*;
use substrate_primitives::u32_trait::{_2, _4};
use cennznet_primitives::{
	AccountIndex, Balance, BlockNumber, Hash, Index, SessionKey, Signature
};
#[cfg(feature = "std")]
use cennznet_primitives::Block as GBlock;
use client::{block_builder::api::runtime::*, runtime_api::{runtime::*, id::*}};
#[cfg(feature = "std")]
use client::runtime_api::ApiExt;
use runtime_primitives::ApplyResult;
use runtime_primitives::transaction_validity::TransactionValidity;
use runtime_primitives::generic;
use runtime_primitives::traits::{Convert, BlakeTwo256, Block as BlockT, DigestFor, NumberFor};
#[cfg(feature = "std")]
use runtime_primitives::traits::ApiRef;
#[cfg(feature = "std")]
use substrate_primitives::AuthorityId;
use version::RuntimeVersion;
use council::{motions as council_motions, voting as council_voting};
#[cfg(feature = "std")]
use council::seats as council_seats;
#[cfg(any(feature = "std", test))]
use version::NativeVersion;
use substrate_primitives::OpaqueMetadata;
use substrate_finality_grandpa_primitives::{runtime::GrandpaApi, ScheduledChange};

#[cfg(any(feature = "std", test))]
pub use runtime_primitives::BuildStorage;
pub use consensus::Call as ConsensusCall;
pub use timestamp::Call as TimestampCall;
pub use balances::Call as BalancesCall;
pub use runtime_primitives::{Permill, Perbill};
pub use timestamp::BlockPeriod;
pub use srml_support::{StorageValue, RuntimeMetadata};

pub use cennznet_primitives::AccountId;

const TIMESTAMP_SET_POSITION: u32 = 0;
const NOTE_OFFLINE_POSITION: u32 = 1;

/// Runtime version.
pub const VERSION: RuntimeVersion = RuntimeVersion {
	spec_name: ver_str!("cennznet"),
	impl_name: ver_str!("centrality-cennznet"),
	authoring_version: 1,
	spec_version: 1,
	impl_version: 0,
	apis: apis_vec!([
		(BLOCK_BUILDER, 1),
		(TAGGED_TRANSACTION_QUEUE, 1),
		(METADATA, 1)
	]),
};

/// Native version.
#[cfg(any(feature = "std", test))]
pub fn native_version() -> NativeVersion {
	NativeVersion {
		runtime_version: VERSION,
		can_author_with: Default::default(),
	}
}

impl system::Trait for Runtime {
	/// The ubiquitous origin type.
	type Origin = Origin;
	/// The index type for storing how many extrinsics an account has signed.
	type Index = Index;
	/// The index type for blocks.
	type BlockNumber = BlockNumber;
	/// The type for hashing blocks and tries.
	type Hash = Hash;
	/// The hashing algorithm used.
	type Hashing = BlakeTwo256;
	/// The header digest type.
	type Digest = generic::Digest<Log>;
	/// The identifier used to distinguish between accounts.
	type AccountId = AccountId;
	/// The header type.
	type Header = generic::Header<BlockNumber, BlakeTwo256, Log>;
	/// The ubiquitous event type.
	type Event = Event;
	/// The ubiquitous log type.
	type Log = Log;
}

impl balances::Trait for Runtime {
	/// The type for recording an account's balance.
	type Balance = Balance;
	/// The type for recording indexing into the account enumeration. If this ever overflows, there
	/// will be problems!
	type AccountIndex = AccountIndex;
	/// What to do if an account's free balance gets zeroed.
	type OnFreeBalanceZero = (Staking, Contract);
	/// Restrict whether an account can transfer funds.
	type EnsureAccountLiquid = Staking;
	/// The uniquitous event type.
	type Event = Event;
}

impl consensus::Trait for Runtime {
	/// The position in the block's extrinsics that the note-offline inherent must be placed.
	const NOTE_OFFLINE_POSITION: u32 = NOTE_OFFLINE_POSITION;
	/// The ubiquitous log type.
	type Log = Log;
	/// The identifier we use to refer to authorities.
	type SessionKey = SessionKey;
	type OnOfflineValidator = Staking;
}

impl timestamp::Trait for Runtime {
	/// The position in the block's extrinsics that the timestamp-set inherent must be placed.
	const TIMESTAMP_SET_POSITION: u32 = TIMESTAMP_SET_POSITION;
	/// A timestamp: seconds since the unix epoch.
	type Moment = u64;
}

/// Session key conversion.
pub struct SessionKeyConversion;
impl Convert<AccountId, SessionKey> for SessionKeyConversion {
	fn convert(a: AccountId) -> SessionKey {
		a.to_fixed_bytes().into()
	}
}

impl session::Trait for Runtime {
	type ConvertAccountIdToSessionKey = SessionKeyConversion;
	type OnSessionChange = Staking;
	type Event = Event;
}

impl staking::Trait for Runtime {
	type OnRewardMinted = Treasury;
	type Event = Event;
}

impl democracy::Trait for Runtime {
	type Proposal = Call;
	type Event = Event;
}

impl council::Trait for Runtime {
	type Event = Event;
}

impl council::voting::Trait for Runtime {
	type Event = Event;
}

impl council::motions::Trait for Runtime {
	type Origin = Origin;
	type Proposal = Call;
	type Event = Event;
}

impl treasury::Trait for Runtime {
	type ApproveOrigin = council_motions::EnsureMembers<_4>;
	type RejectOrigin = council_motions::EnsureMembers<_2>;
	type Event = Event;
}

impl contract::Trait for Runtime {
	type Gas = u64;
	type DetermineContractAddress = contract::SimpleAddressDeterminator<Runtime>;
	type Event = Event;
}

impl upgrade_key::Trait for Runtime {
	type Event = Event;
}

construct_runtime!(
	pub enum Runtime with Log(InternalLog: DigestItem<Hash, SessionKey>) where
		Block = Block,
		UncheckedExtrinsic = UncheckedExtrinsic
	{
		System: system::{default, Log(ChangesTrieRoot)},
		Timestamp: timestamp::{Module, Call, Storage, Config<T>, Inherent},
		Consensus: consensus::{Module, Call, Storage, Config<T>, Log(AuthoritiesChange), Inherent},
		Balances: balances,
		Session: session,
		Staking: staking,
		Democracy: democracy,
		Council: council::{Module, Call, Storage, Event<T>},
		CouncilVoting: council_voting,
		CouncilMotions: council_motions::{Module, Call, Storage, Event<T>, Origin},
		CouncilSeats: council_seats::{Config<T>},
		Treasury: treasury,
		Contract: contract::{Module, Call, Config<T>, Event<T>},
		UpgradeKey: upgrade_key,
	}
);

/// The address format for describing accounts.
pub use balances::address::Address as RawAddress;
/// The address format for describing accounts.
pub type Address = balances::Address<Runtime>;
/// Block header type as expected by this runtime.
pub type Header = generic::Header<BlockNumber, BlakeTwo256, Log>;
/// Unchecked extrinsic type as expected by this runtime.
pub type UncheckedExtrinsic = generic::UncheckedMortalExtrinsic<Address, Index, Call, Signature>;
/// Block type as expected by this runtime.
pub type Block = generic::Block<Header, UncheckedExtrinsic>;
/// A Block signed with a Justification
pub type SignedBlock = generic::SignedBlock<Block>;
/// BlockId type as expected by this runtime.
pub type BlockId = generic::BlockId<Block>;
/// Extrinsic type that has already been checked.
pub type CheckedExtrinsic = generic::CheckedExtrinsic<AccountId, Index, Call>;
/// Executive: handles dispatch to the various modules.
pub type Executive = executive::Executive<Runtime, Block, balances::ChainContext<Runtime>, Balances, AllModules>;

#[cfg(feature = "std")]
pub struct ClientWithApi {
	call: ::std::ptr::NonNull<client::runtime_api::CallApiAt<GBlock>>,
	commit_on_success: ::std::cell::RefCell<bool>,
	initialised_block: ::std::cell::RefCell<Option<GBlockId>>,
	changes: ::std::cell::RefCell<client::runtime_api::OverlayedChanges>,
}

#[cfg(feature = "std")]
unsafe impl Send for ClientWithApi {}
#[cfg(feature = "std")]
unsafe impl Sync for ClientWithApi {}

#[cfg(feature = "std")]
impl ApiExt for ClientWithApi {
	fn map_api_result<F: FnOnce(&Self) -> Result<R, E>, R, E>(&self, map_call: F) -> Result<R, E> {
		*self.commit_on_success.borrow_mut() = false;
		let res = map_call(self);
		*self.commit_on_success.borrow_mut() = true;

		self.commit_on_ok(&res);

		res
	}
}

#[cfg(feature = "std")]
impl client::runtime_api::ConstructRuntimeApi<GBlock> for ClientWithApi {
	fn construct_runtime_api<'a, T: client::runtime_api::CallApiAt<GBlock>>(call: &'a T) -> ApiRef<'a, Self> {
		ClientWithApi {
			call: unsafe {
				::std::ptr::NonNull::new_unchecked(
					::std::mem::transmute(
						call as &client::runtime_api::CallApiAt<GBlock>
					)
				)
			},
			commit_on_success: true.into(),
			initialised_block: None.into(),
			changes: Default::default(),
		}.into()
	}
}

#[cfg(feature = "std")]
impl ClientWithApi {
	fn call_api_at<A: Encode, R: Decode>(
		&self,
		at: &GBlockId,
		function: &'static str,
		args: &A
	) -> client::error::Result<R> {
		let res = unsafe {
			self.call.as_ref().call_api_at(
				at,
				function,
				args.encode(),
				&mut *self.changes.borrow_mut(),
				&mut *self.initialised_block.borrow_mut()
			).and_then(|r|
				R::decode(&mut &r[..])
					.ok_or_else(||
						client::error::ErrorKind::CallResultDecode(function).into()
					)
			)
		};

		self.commit_on_ok(&res);
		res
	}

	fn commit_on_ok<R, E>(&self, res: &Result<R, E>) {
		if *self.commit_on_success.borrow() {
			if res.is_err() {
				self.changes.borrow_mut().discard_prospective();
			} else {
				self.changes.borrow_mut().commit_prospective();
			}
		}
	}
}

#[cfg(feature = "std")]
type GBlockId = generic::BlockId<GBlock>;

#[cfg(feature = "std")]
impl client::runtime_api::Core<GBlock> for ClientWithApi {
	fn version(&self, at: &GBlockId) -> Result<RuntimeVersion, client::error::Error> {
		self.call_api_at(at, "version", &())
	}

	fn authorities(&self, at: &GBlockId) -> Result<Vec<AuthorityId>, client::error::Error> {
		self.call_api_at(at, "authorities", &())
	}

	fn execute_block(&self, at: &GBlockId, block: &GBlock) -> Result<(), client::error::Error> {
		self.call_api_at(at, "execute_block", block)
	}

	fn initialise_block(&self, at: &GBlockId, header: &<GBlock as BlockT>::Header) -> Result<(), client::error::Error> {
		self.call_api_at(at, "initialise_block", header)
	}
}

#[cfg(feature = "std")]
impl client::block_builder::api::BlockBuilder<GBlock> for ClientWithApi {
	fn apply_extrinsic(&self, at: &GBlockId, extrinsic: &<GBlock as BlockT>::Extrinsic) -> Result<ApplyResult, client::error::Error> {
		self.call_api_at(at, "apply_extrinsic", extrinsic)
	}

	fn finalise_block(&self, at: &GBlockId) -> Result<<GBlock as BlockT>::Header, client::error::Error> {
		self.call_api_at(at, "finalise_block", &())
	}

	fn inherent_extrinsics<Inherent: Decode + Encode, Unchecked: Decode + Encode>(
		&self, at: &GBlockId, inherent: &Inherent
	) -> Result<Vec<Unchecked>, client::error::Error> {
		self.call_api_at(at, "inherent_extrinsics", inherent)
	}

	fn check_inherents<Inherent: Decode + Encode, Error: Decode + Encode>(&self, at: &GBlockId, block: &GBlock, inherent: &Inherent) -> Result<Result<(), Error>, client::error::Error> {
		self.call_api_at(at, "check_inherents", &(block, inherent))
	}

	fn random_seed(&self, at: &GBlockId) -> Result<<GBlock as BlockT>::Hash, client::error::Error> {
		self.call_api_at(at, "random_seed", &())
	}
}

#[cfg(feature = "std")]
impl client::runtime_api::TaggedTransactionQueue<GBlock> for ClientWithApi {
	fn validate_transaction(
		&self,
		at: &GBlockId,
		utx: &<GBlock as BlockT>::Extrinsic
	) -> Result<TransactionValidity, client::error::Error> {
		self.call_api_at(at, "validate_transaction", utx)
	}
}

#[cfg(feature = "std")]
impl client::runtime_api::Metadata<GBlock> for ClientWithApi {
	fn metadata(&self, at: &GBlockId) -> Result<OpaqueMetadata, client::error::Error> {
		self.call_api_at(at, "metadata", &())
	}
}

#[cfg(feature = "std")]
impl substrate_finality_grandpa_primitives::GrandpaApi<GBlock> for ClientWithApi {
	fn grandpa_pending_change(&self, at: &GBlockId, digest: &DigestFor<GBlock>)
		-> Result<Option<ScheduledChange<NumberFor<GBlock>>>, client::error::Error> {
		self.call_api_at(at, "grandpa_pending_change", digest)
	}

	fn grandpa_authorities(&self, at: &GBlockId)
		-> Result<Vec<(AuthorityId, u64)>, client::error::Error> {
		self.call_api_at(at, "grandpa_authorities", &())
	}
}

impl_runtime_apis! {
	impl Core<Block> for Runtime {
		fn version() -> RuntimeVersion {
			VERSION
		}

		fn authorities() -> Vec<SessionKey> {
			Consensus::authorities()
		}

		fn execute_block(block: Block) {
			Executive::execute_block(block)
		}

		fn initialise_block(header: <Block as BlockT>::Header) {
			Executive::initialise_block(&header)
		}
	}

	impl Metadata for Runtime {
		fn metadata() -> OpaqueMetadata {
			Runtime::metadata().into()
		}
	}

	impl BlockBuilder<Block, InherentData, UncheckedExtrinsic, InherentData, InherentError> for Runtime {
		fn apply_extrinsic(extrinsic: <Block as BlockT>::Extrinsic) -> ApplyResult {
			Executive::apply_extrinsic(extrinsic)
		}

		fn finalise_block() -> <Block as BlockT>::Header {
			Executive::finalise_block()
		}

		fn inherent_extrinsics(data: InherentData) -> Vec<UncheckedExtrinsic> {
			data.create_inherent_extrinsics()
		}

		fn check_inherents(block: Block, data: InherentData) -> Result<(), InherentError> {
			data.check_inherents(block)
		}

		fn random_seed() -> <Block as BlockT>::Hash {
			System::random_seed()
		}
	}

	impl TaggedTransactionQueue<Block> for Runtime {
		fn validate_transaction(tx: <Block as BlockT>::Extrinsic) -> TransactionValidity {
			Executive::validate_transaction(tx)
		}
	}


	impl GrandpaApi<Block> for ClientWithApi {
		fn grandpa_pending_change(_digest: DigestFor<Block>)
			-> Option<ScheduledChange<NumberFor<Block>>> {
			unimplemented!("Robert, where is the impl?")
		}

		fn grandpa_authorities() -> Vec<(SessionKey, u64)> {
			unimplemented!("Robert, where is the impl?")
		}
	}
}
