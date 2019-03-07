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

# Setup Cargo config
PROJECT_ROOT="$(git rev-parse --show-toplevel)"
export CARGO_HOME="$PROJECT_ROOT/.cargo"
echo "Creating local cargo config with $CARGO_HOME"
mkdir -p $CARGO_HOME

# Use host `git` command to clone dependencies
cat << EOF > "$CARGO_HOME/config"
[net]
git-fetch-with-cli = true
EOF

rustup default nightly

# Create generic rust-builder image from nightly
NIGHTLY_DATE="$(TZ="Pacific/Auckland" date +%Y%m%d)"

if [[ "$(docker images -q rust-builder:$NIGHTLY_DATE 2> /dev/null)" == "" ]]; then
  echo "Building rust-builder image..."
  rustup update nightly
  docker build --no-cache --pull -f docker/rust-builder.Dockerfile -t rust-builder:$NIGHTLY_DATE .
else
  echo "rust-builder image for $NIGHTLY_DATE exists. Not rebuilding..."
fi
