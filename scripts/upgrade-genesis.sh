#!/usr/bin/env bash

echo Updaing LOCAL genesis
cargo run -- --chain=dev build-spec > ./genesis/local/local.json
cargo run -- --chain=dev build-spec --raw > ./genesis/local/genesis.json

echo Updaing DEV genesis
cargo run -- --chain=cennznet-dev-latest build-spec --raw > ./genesis/dev/genesis.json

# echo Updaing UAT genesis
# cargo run -- --chain=cennznet-uat-latest build-spec --raw > ./genesis/uat/genesis.json
