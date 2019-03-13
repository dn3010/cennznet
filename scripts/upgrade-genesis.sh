#!/usr/bin/env bash

echo Build WASM runtime
__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
${__dir}/build.sh

if [ "$1" == "local" ]; then
	echo Updaing LOCAL genesis
	cargo run -- build-spec --chain=dev > ./genesis/local/readable.json
	cargo run -- build-spec --chain=./genesis/local/readable.json --raw > ./genesis/local/genesis.json
elif [ "$1" == "kauri" ]; then
	echo Updaing Kauri genesis
	cargo run -- build-spec --chain=kauri-latest > ./genesis/dev/readable.json
	cargo run -- build-spec --chain=./genesis/dev/readable.json --raw > ./genesis/dev/genesis.json
elif [ "$1" == "rimu" ]; then
	echo Updaing Rimu genesis
	cargo run -- build-spec --chain=rimu-latest > ./genesis/uat/readable.json
	cargo run -- build-spec --chain=./genesis/uat/readable.json --raw > ./genesis/uat/genesis.json
else
	echo "please provide chain name, valid values are: local, kauri, rimu"
    exit 1
fi
