#!/bin/bash
#Prepare the jenkins host
#https://nicksergeant.com/running-supervisor-on-os-x/
#wget https://jenkins.centrality.ai/jenkins/jnlpJars/agent.jar
#java -jar agent.jar -jnlpUrl https://jenkins.centrality.ai/jenkins/computer/mac-os-node/slave-agent.jnlp -secret 2d5f853be8f003627cec04981e2903900a7d6ff6a50bedf2bcd171d31d9f9039 -workDir "/Users/jenkins/workdir"
#eval `ssh-agent -s`
#ssh-add
# update ~/.cargo/config
#[net]
#git-fetch-with-cli = true

curl https://sh.rustup.rs -sSf | sh -s -- -y
source ~/.cargo/env

cargo version
rustup --version

./scripts/init.sh
./scripts/build.sh

export OPENSSL_STATIC=1
cargo build --release

if [ ! -f ./target/release/cennznet ]; then
    echo "Fail to build"
    exit 1
fi
