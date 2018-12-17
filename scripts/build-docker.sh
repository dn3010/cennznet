#!/bin/bash
#
# Usage: ./scripts/build-docker.sh
#
set -e
echo -e "\nStarting cennznet build..."

# Setup a local $CARGO_HOME and fetch dependencies
$(pwd)/scripts/fetch-dependencies.sh

# Create cennznet wasm builder image
if [[ $(docker images -q cennznet-wasm-builder) ]] && [[ $rebuild == 'false' ]]; then
  echo "cennznet-builder image exists. Not rebuilding..."
else
  echo "Building cennznet-builder image..."
  docker build -f $(pwd)/docker/wasm-builder.Dockerfile -t cennznet-wasm-builder $(pwd)
fi

# Build cennznet-node runtime WASM binary
echo -e "\nBuilding runtime wasm..."
docker run --rm \
      -v "$PWD:/home/rust/src" \
      -v "$PWD/.cargo/git:/home/rust/.cargo/git" \
      -v "$PWD/.cargo/registry:/home/rust/.cargo/registry" \
      cennznet-wasm-builder ./scripts/build.sh

# Create cennznet native builder image
if [[ $(docker images -q cennznet-builder) ]] && [[ $rebuild == 'false' ]]; then
  echo "cennznet-builder image exists. Not rebuilding..."
else
  echo "Building cennznet-builder image..."
  docker build -f $(pwd)/docker/native-builder.Dockerfile -t cennznet-builder $(pwd)
fi

# Create cennznet-node native binary
echo -e "\nBuilding cennznet node binary..."
docker run --rm \
  -v "$PWD/.cargo/git:/usr/local/cargo/git" \
  -v "$PWD/.cargo/registry:/usr/local/cargo/registry" \
  -v "$PWD:/usr/src/cennznet-node" \
  cennznet-builder \
  sh -c "cd /usr/src/cennznet-node && cargo build"

# Create a cennznet-node image
echo -e "\nBuilding cennznet node image..."
IMAGE_NAME="${IMAGE_NAME:-cennznet-node}"
docker build -f $(pwd)/docker/Dockerfile -t "$IMAGE_NAME" $(pwd)
