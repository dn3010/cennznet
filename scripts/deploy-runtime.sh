#!/bin/sh

#
# Deploy built runtime wasm to a live networ
#
# Usage:
#   ./scripts/deploy-runtime.sh
set -ex

# Ensure clean clone
echo "Cloning cennz-cli..."
if [ ! -d "cennz-cli" ]; then
	git clone ssh://git@bitbucket.org/centralitydev/cennz-cli
else
	cd cennz-cli
	git pull origin master
	cd ..
fi

# Deploy cennznet-runtime
docker run \
  -v "$(pwd):/cennznet-node" \
  -w "/cennznet-node/cennz-cli"
  node:alpine \
  sh -c \
   "yarn && \
  ./bin/run repl \
  --endpoint=ws://cennznet-node-0.centrality.me:9944 \
    scripts/upgrade-runtime.js \
    Centrality \
    ../runtime/wasm/target/wasm32-unknown-unknown/release/cennznet_runtime.compact.wasm"
