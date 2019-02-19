#!/bin/sh
#
# Setup local rust, cargo, and fetch dependencies
#

# Create local, temp. cargo config
echo "Creating local cargo config..."
CARGO_HOME="$(git rev-parse --show-toplevel)/.cargo"
alias cargo="CARGO_HOME=$CARGO_HOME cargo"
mkdir -p $CARGO_HOME
# Use host `git` command to clone dependencies
cat << EOF > "$CARGO_HOME/config"
[net]
git-fetch-with-cli = true
EOF

# Fetch dependencies locally. Copied into container on build
# This is a workaround to avoid moutning an SSH key into the build container
echo "Fetching project dependencies..."
# Have to fetch resursivley for all project modules as there is no
# `cargo fetch --all` type command to do it automatically
cargo metadata --format-version 1 | jq '.packages | map(.manifest_path)| .[] | select(contains("cennznet-node/.") | not)' | xargs -I{} dirname {} | xargs -I{} sh -c "cd {} && cargo fetch"
# Have to manually fetch the runtime/wasm dependencies
cd "$(git rev-parse --show-toplevel)/runtime/wasm"
cargo fetch
cd "$(git rev-parse --show-toplevel)/"