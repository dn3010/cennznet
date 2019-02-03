#!/usr/bin/env bash

echo Build WASM runtime
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
${__dir}/build.sh

echo Updaing LOCAL genesis
cargo run -- build-spec --chain=dev > ./genesis/local/local.json
cargo run -- build-spec --chain=dev --raw > ./genesis/local/genesis.json

echo Updaing Kauri genesis
cargo run -- build-spec --chain=kauri-latest --raw > ./genesis/dev/genesis.json

# echo Updaing Rimu genesis
# cargo run -- --chain=rimu-latest build-spec --raw > ./genesis/uat/genesis.json
