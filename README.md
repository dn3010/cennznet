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
- Build
    - Make sure your have setup an SSH key with your bitbucket account
        - https://confluence.atlassian.com/bitbucket/set-up-an-ssh-key-728138079.html
        - You can verify it by running `ssh git@bitbucket.org`, which should prompt `logged in as your_bitbucket_user_name.`
    - `./build.sh`
        - compile runtime to wasm
    - `cargo build`
        - compile the node
- Run with as a validator
    - `cargo run -- --dev`
    - or `cennznet --dev`


Note: Ctrl + C can kill the node but it could take some times, you may use `killall -9 cennznet` to force kill it. A robust blockchain application should survive from the harshest conditions.