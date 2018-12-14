#!groovy

pipeline {
    agent {
        label 'linux'
    }

    environment {
        TENANT = 'ea23b9ad-a3ca-4936-8613-68446bd85dde'
        SERVICE_PRINCIPAL = credentials('SERVICE_PRINCIPAL')
        SERVICE_NAME = 'cennznet'
        ACR = credentials('AzureDockerRegistry')
    }

    stages {

        stage('Build CENNZnet image') {
            environment {
                IMAGE_NAME = "centrality/${SERVICE_NAME}:1.0.${BUILD_NUMBER}"
                CARGO_HOME="${WORKSPACE}/.cargo"
                PATH="${CARGO_HOME}/bin:${PATH}"
            }
            steps {
              sh 'sudo apt-get install jq'
              sh './scripts/build-docker.sh'
            }
        }

        stage('Publish CENNZnet image') {
            steps {
                sh './centrality.deploy/publish.sh'
            }
        }

        stage ('Confirm deploy new Runtime') {
            steps {
                timeout(time:1, unit:'HOURS') {
                    input "Confirm deploy new Runtime? Warning!! May brick the chain"
                }
           }
        }

        stage('Deploy new wasm Runtime to chain') {
            steps {
                // Clone cennz-cli
                sh 'git clone ssh://git@bitbucket.org/centralitydev/cennz-cli &&\
                    cd cennz-cli \
                    && yarn install'
                // Submit the wasm Tx
                // TODO: Update to use `cennz-cli <subcommand>` with npm install or exec in latest cennz-cli docker container
                sh './bin/run repl --endpoint="ws://cennznet-node-0.centrality.me:9944" \
                                   scripts/upgrade-runtime.js \
                                   Centrality \
                                   ../runtime/wasm/target/wasm32-unknown-unknown/release/cennznet_runtime.compact.wasm && \
                    cd .. && rm -rf cennz-cli'
            }
        }
    }

}
