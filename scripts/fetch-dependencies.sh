#!/bin/sh
#
# Setup local rust, cargo, and fetch dependencies
#

# Create local, temp. cargo config
echo "Creating local cargo config..."
CARGO_HOME="$(pwd)/.cargo"
alias cargo="CARGO_HOME=$CARGO_HOME cargo +nightly"
mkdir -p $CARGO_HOME
# Use host `git` command to clone dependencies
cat << EOF > "$CARGO_HOME/config"
[net]
git-fetch-with-cli = true
EOF

# Use BUILD_NUMBER as a proxy for running in Jenkins
if [ -n "$BUILD_NUMBER" ]; then
  echo "Install rust nightly toolchain (for Jenkins)"
  curl https://sh.rustup.rs -sSf > rustup-install.sh
  chmod +x rustup-install.sh
  ./rustup-install.sh -y
  export PATH="$CARGO_HOME/bin":$PATH
  rustup toolchain install nightly
fi

# Fetch dependencies locally. Copied into container on build
# This is a workaround to avoid moutning an SSH key into the build container
echo "Fetching project dependencies..."
# Have to fetch resursivley for all project modules as there is no
# `cargo fetch --all` type command to do it automatically
cargo metadata | jq '.packages | map(.manifest_path)| .[] | select(contains("cennznet-node/.") | not)' | xargs -I{} dirname {} | xargs -I{} sh -c "cd {} && cargo fetch"
