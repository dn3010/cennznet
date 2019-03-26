#!groovy

pipeline {
    
    agent {
        label 'linux-agent1'
    }

    options {
      ansiColor('xterm')
    }

    environment {
        TENANT = 'ea23b9ad-a3ca-4936-8613-68446bd85dde'
        SERVICE_PRINCIPAL = credentials('SERVICE_PRINCIPAL')
        SERVICE_NAME = 'cennznet'
        ACR = credentials('AzureDockerRegistry')
        NAMESPACE = 'cennznet'
        SUBCHART= 'cennznet-node'
        IMAGE_NAME = "centrality/${SERVICE_NAME}:1.0.${BUILD_NUMBER}"
        IS_EKS='false'
        CONTAINER="k8s-aws-terraform:1.0.20"
    }

    stages {


        stage('Install dependencies') {
            environment {
                PATH="${HOME}/.cargo/bin:${PATH}"
            }
            steps {
              sh 'bash ./ci/pre-build.sh'
              sh 'bash ./scripts/fetch-dependencies.sh'
            }
        }


        stage('Build WASM') {
            environment {
                PATH="${HOME}/.cargo/bin:${PATH}"
            }
            steps {
              sh 'bash ./ci/build-wasm-docker.sh'
            }
        }

        stage('Run Unit Tests') {
            environment {
                PATH="${HOME}/.cargo/bin:${PATH}"
            }
            steps {
              sh 'bash ./ci/unit-test-docker.sh'
            }
        }

        stage('Build CENNZnet image') {
            environment {
                PATH="${HOME}/.cargo/bin:${PATH}"
            }
            steps {
              sh 'bash ./ci/build-image.sh'
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
            sh 'bash ./ci/wipe-workspace.sh'
        }
    }


}
