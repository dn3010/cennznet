#!/bin/bash
#
# Setup local rust, cargo, and fetch dependencies
#

# Create local, temp. cargo config
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
export CARGO_HOME="$PROJECT_ROOT/.cargo"
echo "Creating local cargo config with $CARGO_HOME"
mkdir -p $CARGO_HOME
# Use host `git` command to clone dependencies
cat << EOF > "$CARGO_HOME/config"
[net]
git-fetch-with-cli = true
EOF

echo "Updating rust to use nightly"
rustup default nightly
rustup update nightly

# Fetch dependencies locally. Copied into container on build
# This is a workaround to avoid moutning an SSH key into the build container
echo "Fetching project dependencies..."
# Have to fetch resursivley for all project modules as there is no
# `cargo fetch --all` type command to do it automatically
cargo +nightly metadata --format-version 1 | jq '.packages | map(.manifest_path)| .[] | select(contains("cennznet-node/.") | not)' | xargs -I{} dirname {} | xargs -I{} sh -c "cd {} && cargo fetch"
# Have to manually fetch the runtime/wasm dependencies
pushd "$PROJECT_ROOT/runtime/wasm"
cargo fetch
popd