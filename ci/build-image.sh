#!/bin/bash
set -e

# Either: 'debug' or 'release', defaults to 'release'
BUILD_PROFILE=${BUILD_PROFILE:-"release"}
BUILD_CMD="cargo +nightly build --release"

if [ $BUILD_PROFILE == "debug" ]; then
      BUILD_CMD="cargo +nightly build"
fi

# Create cennznet-node native binary
echo -e "\nBuilding cennznet node binary..."
NIGHTLY_DATE="$(date +%Y%m%d)"
docker run --user "$(id -u)":"$(id -g)" \
       -t --rm \
       -v "$PWD:/cennznet" \
       rust-builder:$NIGHTLY_DATE $BUILD_CMD

# Create a cennznet-node image
echo -e "\nBuilding cennznet node image..."
IMAGE_NAME="${IMAGE_NAME:-cennznet-node}"
docker build --pull \
       -f docker/binary.Dockerfile \
       -t "$IMAGE_NAME" \
       --build-arg PROFILE="$BUILD_PROFILE" .
