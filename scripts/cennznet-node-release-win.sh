#!/bin/bash
curl https://sh.rustup.rs -sSf | sh -s -- -y
#source ~/.cargo/env

# Setup ssh-agent for private repo for rust build on windows
# setup ssh-agent via pageant.exe
# can generate ppk with puttygen.exe frm id_rsa
# then import key to pageant.exe
# https://www.chiark.greenend.org.uk/~sgtatham/putty/latest.html

cargo version
rustup --version
ssh-add -L
cat ~/.cargo/config
echo $PATH
echo $OPENSSL_DIR
echo $OPENSSL_LIB_DIR
echo $OPENSSL_STATIC
echo $HOME

./scripts/init.sh
./scripts/build.sh

# fix openssl static linking issue
#https://github.com/sfackler/rust-openssl/issues/935
#vcpkg install openssl:x64-windows-static
#export OPENSSL_STATIC=1
#export OPENSSL_DIR="c:\Users\centrality\vcpkg\installed\x64-windows-static"
#export OPENSSL_LIB_DIR="c:\Users\centrality\vcpkg\installed\x64-windows-static\lib"

# fix MSVCP140.dll missing issue
# https://github.com/rust-lang/libc/issues/290
#~/.cargo/config
#[target.x86_64-pc-windows-msvc]
#rustflags = ["-Ctarget-feature=+crt-static", "-Zunstable-options"]
RUSTFLAGS='-C target-feature=+crt-static' cargo build --release

if [ ! -f ./target/release/cennznet.exe ]; then
    echo "Fail to build"
    exit 1
fi
