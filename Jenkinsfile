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
               echo 'Starting build docker image'
               
               script { 
                def app = docker.build("${REPO}/${IMAGE}:${TAG}") 
               }
            }
        }
        stage("Scan image") {
            steps {
                sh "/var/jenkins_home/app/run_cbctl.sh"
                sh "/var/jenkins_home/app/run_cbctl.sh >> test.txt"
            }
        }
       
        stage("Push image") {
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'docker-hub'){
                    app.push()  
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
            slackUploadFile filePath: "test.txt", initialComment: "Test declarative pipeline. Scan results for [Jenkins] '${env.JOB_NAME}' ${env.BUILD_URL}"
        }

        failure {
            slackSend message: "FAILED: ${env.BUILD_URL}"
        }
    }
}
