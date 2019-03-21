# CENNZnet Node

CENNZnet node based on Substrate

## Development

__Install rust__
```bash
# Install rustup
curl -sSf https://static.rust-lang.org/rustup.sh | sh

# Make installed tool available to current shell
source ~/.cargo/env

# Install nightly version of rust and required tools
./scripts/init.sh
```


__Build__
Ensure you have setup an SSH key with your bitbucket account: [https://confluence.atlassian.com/bitbucket/set-up-an-ssh-key-728138079.html]()
You can verify it by running `ssh git@bitbucket.org`, which should prompt `logged in as your_bitbucket_user_name.`
If you are still unable to fetch, [follow these instructions](https://github.com/rust-lang/cargo/issues/2078#issuecomment-434388584)

```bash
# compile runtime to wasm
./scripts/build.sh

# compile the node
cargo build
```


__Run__
```bash
# Join Rimu CENNZnet net
cargo run
# or
./target/debug/cennznet

# Join Kauri CENNZnet net
cargo run -- --chain=kauri
# or
./target/debug/cennznet --chain=kauri

# Run your own testnet with a validator
cargo run -- --dev
# or
./target/debug/cennznet --dev
```


__Purge chain__
```bash
# For Rimu CENNZnet net
cargo run -- purge-chain
# or
./target/debug/cennznet purge-chain

# For Kauri CENNZnet net
cargo run -- purge-chain --chain=kauri
# or
./target/debug/cennznet purge-chain --chain=kauri

# For local testnet
cargo run -- purge-chain --dev
# or
./target/debug/cennznet purge-chain --dev
```


__Telemetry__
Add command argument `--telemetry-url=ws://cennznet-telemetry.centrality.me:1024 --name your_name` to report information to telemetry server

You can then view it at [http://cennznet-telemetry.centrality.me/]()


Note: Ctrl + C can kill the node but it could take some times, you may use `killall -9 cennznet` to force kill it. A robust blockchain application should survive from the harshest conditions.


## Docker build
To create a local docker image run:
```bash
./scripts/build-docker

# Rebuild builder images (see ./docker/)
rebuild=true ./scripts/build-docker
```

## Run with a prebuilt image from CI

Firstly, we need to authenticate to Centrality's azure container registry (ACR)
```bash
# Get ACR credentials from k8s
# !! will overwrite an existing .dockercfg
kubectl get secret registry-secret -o json | jq -r .data.\".dockercfg\" | base64 -D > ~/.dockercfg

# Authenticate to the ACR
docker login centralitycontainerregistry-on.azurecr.io
```

Run a dockerized node and connect to cennznet dev.
Set `--name` to your own / desired name.
Set `1.0.48` tag to the desired build*.

```bash
docker run centralitycontainerregistry-on.azurecr.io/centrality/cennznet:1.0.48 \
cennznet --name=cennzational \
         --telemetry-url=ws://cennznet-telemetry.centrality.me:1024
```

You may check [https://jenkins.centrality.ai/jenkins/job/cennznet-node/]()) to find the latest build number.
*In future a tag of `:latest` should suffice as the latest release.
However, we currently only release images tagged by build number.

## Quick start guide

### Start with pre-build docker image

Install docker and docker-compose

remove settings in docker-compose.override.yml

Follow instruction above login to centrality docker registry

Start multiple nodes
```bash
make up
```

Check logs
```bash
make logs
or
make logs telemetry
```
Open telemetry UI
```bash
open http://localhost:5000
```

Stop all nodes
```bash
make stop
```

update docker-compose.yml for different node configurations, then run
```bash
make up
```

### Host and Connect to a local network

* build cennznet-node:latest docker image
```bash
./scripts/build-docker.sh
```

* update ip address to the host network ip in local.json, eg: replace 10.9.30.51 to your network ip

* connect to the local network
```bash
cennznet-node --chain=local.json --telemetry-url=ws://localhost:1024 --name=local-test
```

Open telemetry UI
```bash
open http://localhost:5000
```

### Make a release

- Ensure changelog.md is up to date
- For Kauri release:
	- Generate a new genesis file for local: `./scripts/upgrade-genesis.sh local`
	- Generate a new genesis file for Kauri: `./scripts/upgrade-genesis.sh kauri`
	- Commit genesis file and tag it with the current runtime version
	- Bump `spec_version` and `impl_version` in runtime/src/lib.rs
	- Bump Cargo.toml
	- Ensure there is new version entry in changelog.md
	- Ensure all changes are commited
	- Deploy the change (Ask Bryan or Cameron if you don't know how to do this)
		- Can be reset Kauri nodes and redeploy them
		- Or perform an on-chain upgrade with sudo key
- For Rimu release:
	- Checkout `stable` branch
	- Merge the last tagged version
	- Update Rimu network name version in src/chain_spec.rs
	- Generate a new genesis file for Rimu: `./scripts/upgrade-genesis.sh rimu`
	- Ensure all changes are commited
	- Deploy the change (Ask Bryan or Cameron if you don't know how to do this)
		- Can be reset Kauri nodes and redeploy them
		- Or perform an on-chain upgrade with sudo key
	- Cherry pick or merge changes from `stable` to `master`


