#!/bin/bash

#Prepare the jenkins host
#wget https://jenkins.centrality.ai/jenkins/jnlpJars/agent.jar
#java -jar agent.jar -jnlpUrl https://jenkins.centrality.ai/jenkins/computer/linux-rust/slave-agent.jnlp -secret 3900e95b8945b977688847c4c5961ff249a0bb82d7a0400651ddc3f2e6848e3d -workDir "/Users/jenkins/workdir"
#sudo apt-get install -y git curl gcc pkg-config clang libssl-dev


curl https://sh.rustup.rs -sSf | sh -s -- -y
source ~/.cargo/env

cargo version
rustup --version

whoami
pwd
uname

echo $SSH_RSA_FILE_PATH
echo $GEMFURY_TOKEN

./scripts/init.sh
./scripts/build.sh
cargo build --release

if [ ! -f ./target/release/cennznet ]; then
    echo "Fail to build"
    exit 1
fi
