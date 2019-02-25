#!/bin/sh
#
# Clean build related artifacts
#
# Usage:
#   ./scripts/clean.sh
#
echo "Cleaning cargo cache..."
rm -rf .cargo/
rm -rf target/
rm -rf runtime/wasm/target/
