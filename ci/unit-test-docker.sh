#!/bin/bash

set -e

NIGHTLY_DATE="$(date +%Y%m%d)"

# Run unit test
echo -e "\nRunning unit test"
docker run --user "$(id -u)":"$(id -g)" \
      -t --rm \
      -v "$PWD:/cennznet" \
      rust-builder:$NIGHTLY_DATE ./scripts/unit-test.sh