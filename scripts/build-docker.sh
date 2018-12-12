#!/bin/sh
#
# Usage: ./scripts/build-docker.sh
#
echo
echo "Starting cennznet build..."
echo

# Setup a local $CARGO_HOME and fetch dependencies
echo
echo "Fetching project dependencies..."
echo
$(pwd)/scripts/fetch-dependencies.sh

# Create cennznet wasm builder image
if [[ "$(docker images -q cennznet-wasm-builder 2> /dev/null)" == "" || -n "$rebuild" ]]; then
  docker build -f $(pwd)/docker/wasm-builder.Dockerfile -t cennznet-wasm-builder $(pwd)
fi
# Build cennznet-node runtime WASM binary
echo
echo "Building runtime wasm..."
echo
docker run --rm -it \
      -v "$PWD:/home/rust/src" \
      -v "$PWD/.cargo/git:/home/rust/.cargo/git" \
      -v "$PWD/.cargo/registry:/home/rust/.cargo/registry" \
      cennznet-wasm-builder ./scripts/build.sh

# Create cennznet builder image
if [[ "$(docker images -q cennznet-builder 2> /dev/null)" == "" || -n "$rebuild" ]]; then
    docker build -f $(pwd)/docker/wasm-builder.Dockerfile -t cennznet-builder $(pwd)
fi
# Create cennznet-node native binary
echo
echo "Building cennznet node binary..."
echo
docker run --rm -it \
  -v "$PWD/.cargo/git:/root/.cargo/git" \
  -v "$PWD/.cargo/registry:/root/.cargo/registry" \
  -v "$PWD:/cennznet-node" \
  cennznet-builder \
  cargo build

# Create a cennznet-node image
echo
echo "Building cennznet node image..."
echo
IMAGE_NAME="${IMAGE_NAME:-cennznet-node}"
docker build -f $(pwd)/docker/Dockerfile -t "$IMAGE_NAME" $(pwd)
