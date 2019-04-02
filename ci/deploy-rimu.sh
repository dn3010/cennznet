#!/bin/bash

# A hack to deploy a specific version and image with helm

GIT_SHORT="${GIT_COMMIT:0:8}"
IMAGE_NAME="${IMAGE_NAME:-cennznet}"

export IMAGE_TAG="rimu-$GIT_SHORT"
export VERSION="$(grep package -C 5 Cargo.toml | grep version | cut -d \" -f2)"

export SCRIPT="cennznet"

cd "$(git rev-parse --show-toplevel)"
./centrality.deploy/aws/helm/deploy.sh