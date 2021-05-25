#!/usr/bin/env groovy
pipeline {
    agent any
    environment {
        IMAGE = "nodeapp"
	REPO = "jbarosin"
	TAG = "dp"
        REGISTRY_ADDRESS = "registry.hub.docker.com"

    }

    stages {

        stage("Build image") {
            steps {
               echo 'Starting build docker image'
               
               script { 
                  app = docker.build("${REGISTRY_ADDRESS}/${REPO}/${IMAGE}") 
               }
            }
        }
        stage("Scan image") {
            steps {
                sh "/var/jenkins_home/app/run_cbctl.sh"
                sh "/var/jenkins_home/app/cbctl image scan ${REPO}/${IMAGE} -o json >> cbctl_scan_${REPO}_${IMAGE}_${env.BUILD_NUMBER}.json"
            }
        }
       
        stage("Push image") {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub'){
                    app.push("${TAG}")  
                        } 
                    } 
                } 
        }
    }
    
    post {
        always {
            sh "echo 'done!'"
        }

        success {
            slackUploadFile filePath: "cbctl_scan_${REPO}_{$IMAGE}_${env.BUILD_NUMBER}.json", initialComment: "Test declarative pipeline. Scan results for [Jenkins] '${env.JOB_NAME}' ${env.BUILD_URL}"
        }

        failure {
            slackSend message: "FAILED!: ${env.BUILD_URL}"
        }
    }
}
