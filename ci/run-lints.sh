#!/bin/bash
set -e

NIGHTLY_DATE="$(date +%Y%m%d)"

docker run --user "$(id -u)":"$(id -g)" \
      -t --rm \
      -v "$PWD:/cennznet" \
      rust-builder:$NIGHTLY_DATE cargo +nightly fmt --all -- --check
