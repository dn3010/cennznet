//!
//! CENNZX-SPOT Types
//!
//#[macro_use]
//extern crate uint;
use core::convert::TryInto;
//
construct_uint! {
	/// 128-bit unsigned integer.
	pub struct U128(2);
}

construct_uint! {
	/// 256-bit unsigned integer.
	pub struct U256(4);
}

use parity_codec::{Compact, CompactAs, Decode, Encode};
use runtime_primitives::traits::As;

/// FeeRate S.F precision
const SCALE_FACTOR: u128 = 1_000_000;

/// FeeRate (based on Permill), uses a scale factor
/// Inner type is `u128` in order to support compatibility with `generic_asset::Balance` type
#[cfg_attr(feature = "std", derive(Serialize, Deserialize, Debug))]
#[derive(Encode, Decode, Default, Copy, Clone, PartialEq, Eq)]
pub struct FeeRate(u128);

impl FeeRate {
	/// Create FeeRate as a decimal where `x / 1000`
	pub fn from_milli(x: u128) -> FeeRate {
		FeeRate(x * SCALE_FACTOR / 1000)
	}

	/// Create a FeeRate from a % i.e. `x / 100`
	pub fn from_percent(x: u128) -> FeeRate {
		FeeRate(x * SCALE_FACTOR / 100)
	}

	/// Divide a `As::as_<u128>` supported numeric by a FeeRate
	pub fn div<N: As<u128>>(lhs: N, rhs: FeeRate) -> N {
		N::sa(lhs.as_() * SCALE_FACTOR / rhs.0)
	}

	/// Divide a `As::as_<u128>` supported numeric by a FeeRate
	pub fn safe_div<N: As<u128>>(lhs: N, rhs: FeeRate) -> rstd::result::Result<N, &'static str> {
		//N::sa(lhs.as_() * SCALE_FACTOR / rhs.0)
		let lhs_uint = U256::from(lhs.as_());
		let scale_factor_uint = U256::from(SCALE_FACTOR);
		let rhs_uint = U256::from(rhs.0);
		let res: Result<u128, &'static str> = (lhs_uint * scale_factor_uint / rhs_uint).try_into();

		ensure!(res.is_ok(), "Overflow error");
		Ok(N::sa(res.unwrap()))
	}

	//Self - lhs and b - rhs
	pub fn safe_mul<N: As<u128>>(lhs: FeeRate, rhs: N) -> N
	where
		N: Clone,
		N: As<u128>
			+ rstd::ops::Rem<N, Output = N>
			+ rstd::ops::Div<N, Output = N>
			+ rstd::ops::Mul<N, Output = N>
			+ rstd::ops::Add<N, Output = N>,
	{
		let million = N::sa(SCALE_FACTOR);
		let part = N::sa(lhs.as_());

		let rem_multiplied_divided = {
			let rem = rhs.clone() % million.clone();

			// `rem` is inferior to one million, thus it fits into u128
			let rem_u128: u128 = rem.as_();

			// `lhs` and `rem` are inferior to one million, thus the product fits into u128
			let rem_multiplied_u128 = rem_u128 * lhs.0 as u128;

			let rem_multiplied_divided_u128 = rem_multiplied_u128 / 1_000_000;

			// `rem_multiplied_divided` is inferior to b, thus it can be converted back to N type
			N::sa(rem_multiplied_divided_u128)
		};

		(rhs / million) * part + rem_multiplied_divided
	}

	/// Returns the equivalent of 1 or 100%
	pub fn one() -> FeeRate {
		FeeRate(SCALE_FACTOR)
	}
}

impl As<u128> for FeeRate {
	fn as_(self) -> u128 {
		self.0
	}
	/// Convert `u128` into a FeeRate
	fn sa(x: u128) -> Self {
		FeeRate(x)
	}
}

impl rstd::ops::Add<Self> for FeeRate {
	type Output = Self;
	fn add(self, rhs: FeeRate) -> Self::Output {
		FeeRate(self.0 + rhs.0)
	}
}

impl CompactAs for FeeRate {
	type As = u128;
	fn encode_as(&self) -> &u128 {
		&self.0
	}
	fn decode_from(x: u128) -> FeeRate {
		FeeRate(x)
	}
}

impl From<Compact<FeeRate>> for FeeRate {
	fn from(x: Compact<FeeRate>) -> FeeRate {
		x.0
	}
}

#[cfg(test)]
mod tests {
	use super::*;

	#[test]
	fn div_works() {
		let fee_rate = FeeRate::from_percent(110);
		assert_eq!(FeeRate::div(10, fee_rate), 9); // Float value would be 9.0909

		let fee_rate = FeeRate::from_percent(10);
		assert_eq!(FeeRate::div(10, fee_rate), 100);
	}

	#[test]
	fn safe_div_works() {
		let fee_rate = FeeRate::from_percent(110);
		assert_ok!(FeeRate::safe_div(10, fee_rate), 9); // Float value would be 9.0909

		let fee_rate = FeeRate::from_percent(10);
		assert_ok!(FeeRate::safe_div(10, fee_rate), 100);
	}

	#[test]
	fn add_works() {
		let fee_rate = FeeRate::from_percent(50) + FeeRate::from_percent(12);
		assert_eq!(fee_rate, FeeRate::from_percent(62));
	}

	#[test]
	fn safe_mul_works() {
		let fee_rate = FeeRate::from_percent(50);
		assert_eq!(FeeRate::safe_mul(fee_rate, 2), 1);
	}
}
