# CENNZnet Node

CENNZnet node based on Substrate

## Development

- Install rust
    - `curl -sSf https://static.rust-lang.org/rustup.sh | sh`
        - install rustup
    - `source ~/.cargo/env`
        - make installed tool available to current shell
    - `./init.sh`
        - install nightly version of rust and required tools
        *NOTE:* This needs to go after the SSH setup and fetch!
- Build
    - Make sure your have setup an SSH key with your bitbucket account
        - https://confluence.atlassian.com/bitbucket/set-up-an-ssh-key-728138079.html
        - You can verify it by running `ssh git@bitbucket.org`, which should prompt `logged in as your_bitbucket_user_name.`
        - If you are still unable to fetch, [following this instruction](https://github.com/rust-lang/cargo/issues/2078#issuecomment-434388584)
    - `./build.sh`
        - compile runtime to wasm
    - `cargo build`
        - compile the node
- Run
    - Join CENNZnet DEV net
        - `cargo run`
        - or `./target/debug/cennznet`
    - Run your own testnet with a validator
        - `cargo run -- --dev`
        - or `./target/debug/cennznet --dev`
- Purge chain
    - For CENNZnet DEV net
        - `cargo run -- purge-chain`
        - or `./target/debug/cennznet purge-chain`
    - For local testnet
        - `cargo run -- --dev purge-chain`
        - or `./target/debug/cennznet --dev purge-chain`
- Telemetry
    - Add command argument `--telemetry-url=ws://cennznet-telemetry.centrality.me:1024 --name your_name` to report information to telemetry server
    - You can then view it at http://cennznet-telemetry.centrality.me/



Note: Ctrl + C can kill the node but it could take some times, you may use `killall -9 cennznet` to force kill it. A robust blockchain application should survive from the harshest conditions.