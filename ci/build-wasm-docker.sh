#!/bin/bash

set -e

NIGHTLY_DATE="$(date +%Y%m%d)"

# Build cennznet-node runtime WASM binary
echo -e "\nBuilding runtime wasm..."
docker run --user "$(id -u)":"$(id -g)" \
      -t --rm \
      -v "$PWD:/cennznet" \
      rust-builder:$NIGHTLY_DATE ./scripts/build-wasm.sh
