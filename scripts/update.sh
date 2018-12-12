#!/usr/bin/env bash

#
# Usage: ./scripts/update.sh
#

cargo update
cargo check

cd $(pwd)/runtime/wasm
cargo update

cd $(pwd)
./scripts/build.sh
cargo run
