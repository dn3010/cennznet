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
              sh './scripts/build-docker.sh'
            }
        }

        stage('Publish CENNZnet image') {
            steps {
                sh './centrality.deploy/publish.sh'
            }
        }
    }
}
