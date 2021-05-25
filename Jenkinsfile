#!/usr/bin/env groovy
pipeline {
    agent any

    environment {
        IMAGE = "nodeapp"
	REPO = "jbarosin"
	TAG = "dp"
        TEST_CONTAINER = "${env.TEST_PREFIX}-${env.BUILD_NUMBER}"
        REGISTRY_ADDRESS = "https://registry.hub.docker.com"

    }

    stages {

        stage("Build image") {
            steps {
                sh "docker build . -t ${REPO}/${IMAGE}:${TAG}"
                waitUntilServicesReady
            }
        }

        stage("Scan image") {
            steps {
                sh "/var/jenkins_home/app/run_cbctl.sh"
                sh "/var/jenkins_home/app/run_cbctl.sh >> test.txt"
                waitUntilServicesReady
            }
        }
    }

    post {
        always {
            sh "echo 'done!'"
        }

        success {
            slackUploadFile filePath: "test.txt", initialComment: "Test declarative pipeline. Scan results for [Jenkins] '${env.JOB_NAME}' ${env.BUILD_URL}"

        }

        failure {
            slackSend "FAILED: : ${env.BUILD_URL}"
        }
    }
}
