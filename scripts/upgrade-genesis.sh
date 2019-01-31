#!/usr/bin/env bash

echo Build WASM runtime
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
${__dir}/build.sh

echo Updaing LOCAL genesis
cargo run -- build-spec --chain=dev > ./genesis/local/local.json
cargo run -- build-spec --chain=dev --raw > ./genesis/local/genesis.json

echo Updaing DEV genesis
cargo run -- build-spec --chain=cennznet-dev-latest --raw > ./genesis/dev/genesis.json

# echo Updaing UAT genesis
# cargo run -- --chain=cennznet-uat-latest build-spec --raw > ./genesis/uat/genesis.json
