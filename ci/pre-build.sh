#!/bin/bash


if ! command -v rustup; then
  echo "Install rust nightly toolchain (for Jenkins)"
  curl https://sh.rustup.rs -sSf > ci/rustup-install.sh
  chmod +x ci/rustup-install.sh
  ./ci/rustup-install.sh -y
fi

set -e

# Clean build
if [[ $CLEAN_CARGO == 'true' ]]; then
  ./scripts/clean-cargo.sh
fi

# Setup a local $CARGO_HOME and fetch dependencies
./scripts/fetch-dependencies.sh

# Create generic rust-builder image from nightly
NIGHTLY_DATE="$(date +%Y%m%d)"

if [[ "$(docker images -q rust-builder:$NIGHTLY_DATE 2> /dev/null)" == "" ]]; then
  echo "Building rust-builder image..."
  docker build --no-cache --pull -f docker/rust-builder.Dockerfile -t rust-builder:$NIGHTLY_DATE .
else
  echo "rust-builder image for $NIGHTLY_DATE exists. Not rebuilding..."
fi