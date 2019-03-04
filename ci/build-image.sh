#!/bin/bash

set -e

NIGHTLY_DATE="$(date +%Y%m%d)"

# Create cennznet-node native binary
echo -e "\nBuilding cennznet node binary..."
docker run --user "$(id -u)":"$(id -g)" \
      -t --rm \
      -v "$PWD:/cennznet" \
      rust-builder:$NIGHTLY_DATE ./scripts/build-binary.sh

# Create a cennznet-node image
echo -e "\nBuilding cennznet node image..."
IMAGE_NAME="${IMAGE_NAME:-cennznet-node}"
docker build --pull -f docker/binary.Dockerfile -t "$IMAGE_NAME" .