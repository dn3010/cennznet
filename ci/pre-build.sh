#!/bin/bash

if ! command -v rustup; then
  echo "Install rust nightly toolchain (for Jenkins)"
  curl https://sh.rustup.rs -sSf > ci/rustup-install.sh
  chmod +x ci/rustup-install.sh
  ./ci/rustup-install.sh -y
fi