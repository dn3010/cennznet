#!/bin/sh

#
# Deploy built runtime wasm to a live networ
#
# Usage:
#   ./scripts/deploy-runtime.sh
set -ex

# Ensure clean clone
echo "Cloning cennz-cli..."
rm -rf cennz-cli; git clone ssh://git@bitbucket.org/centralitydev/cennz-cli

# Deploy cennznet-runtime
docker run \
  -v "$(pwd):/cennznet-node" \
  node:alpine \
  sh -c \
  "cd cennz-cli && \
   yarn && \
  ./bin/run repl \
  --endpoint="ws://cennznet-node-0.centrality.me:9944" \
    scripts/upgrade-runtime.js \
    Centrality \
    ../runtime/wasm/target/wasm32-unknown-unknown/release/cennznet_runtime.compact.wasm"
