#!groovy

pipeline {
    agent {
        label 'linux-agent1'
    }

    environment {
        TENANT = 'ea23b9ad-a3ca-4936-8613-68446bd85dde'
        SERVICE_PRINCIPAL = credentials('SERVICE_PRINCIPAL')
        SERVICE_NAME = 'cennznet'
        ACR = credentials('AzureDockerRegistry')
        NAMESPACE = 'cennznet'
        SUBCHART= 'cennznet-node'
        IMAGE_NAME = "centrality/${SERVICE_NAME}:1.0.${BUILD_NUMBER}"
    }

    stages {

        stage('Build CENNZnet image') {
            environment {
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

        stage('Deploy CENNZnet to Kubernetes on AWS (Dev)') {
          environment {
            AWS_ACCESS_KEY  = credentials('TF_AWS_ACCESS_KEY')
            AWS_SECRET_KEY = credentials('TF_AWS_SECRET_KEY')
            AWS_CLUSTER_NAME = credentials('DEV_AWS_CLUSTER_NAME')
            AWS_CLUSTER_URL = credentials('DEV_AWS_CLUSTER_URL')
            ENV = 'dev'
            JENKINS_AWS_K8S_CERTIFICATE = credentials('DEV_JENKINS_AWS_K8S_CERTIFICATE')
            JENKINS_AWS_K8S_KEY = credentials('DEV_JENKINS_AWS_K8S_KEY')
            JENKINS_AWS_K8S_CA = credentials('DEV_JENKINS_AWS_K8S_CA')
          }
          steps {
            sh './centrality.deploy/aws/helm/deploy.sh'
          }
        }

        // stage ('Confirm deploy new Runtime') {
        //     steps {
        //         timeout(time:1, unit:'HOURS') {
        //             input "Confirm deploy new Runtime? Warning!! May brick the chain"
        //         }
        //    }
        // }

        // stage('Deploy new wasm Runtime to chain') {
        //     steps {
        //         sh './scripts/deploy-runtime.sh'
        //     }
        // }

        stage ('Confirm UAT deploy') {
            steps {
                timeout(time:1, unit:'HOURS') {
                input "Confirm UAT deploy?"
                }
            }
        }

        stage('Deploy CENNZnet to Kubernetes on AWS (Uat)') {
          environment {
            AWS_ACCESS_KEY  = credentials('TF_AWS_ACCESS_KEY')
            AWS_SECRET_KEY = credentials('TF_AWS_SECRET_KEY')
            AWS_CLUSTER_NAME = credentials('UAT_AWS_CLUSTER_NAME')
            AWS_CLUSTER_URL = credentials('UAT_AWS_CLUSTER_URL')
            ENV = 'uat'
            JENKINS_AWS_K8S_CERTIFICATE = credentials('UAT_JENKINS_AWS_K8S_CERTIFICATE')
            JENKINS_AWS_K8S_KEY = credentials('UAT_JENKINS_AWS_K8S_KEY')
            JENKINS_AWS_K8S_CA = credentials('UAT_JENKINS_AWS_K8S_CA')
          }
          steps {
            sh './centrality.deploy/aws/helm/deploy.sh'
          }
        }

    }
    post {
        always {
            echo "pipeline post always"
            sh 'bash ./ci/cleanup.sh'
        }
    }


}
