node {
    def app

    stage('Clone repository') {
        /* Cloning the Repository to our Workspace */

        checkout scm
    }

    stage('logstash-test') {
        try {
        // do something that fails
            sh "exit 1"
            currentBuild.result = 'SUCCESS'
        } catch (Exception err) {
        currentBuild.result = 'FAILURE'
           }
        echo "RESULT: ${currentBuild.result}"
        logstashSend failBuild: true, maxLines: 25 
    }    

    stage('Build image') {
        /* This builds the actual image */

        app = docker.build("jbarosin/nodeapp")
    }

    stage('Test image') {
        
        app.inside {
            echo "Tests passed"
            echo "Current build lookin: ${currentBuild.currentResult}"
        }
    }
    withEnv(["BUILD_NUMBER_SCAN_OUTFILE=cbctl_scan_${currentBuild.number}.json", "REPO=jbarosin", "IMAGE=nodeapp"]){
        stage('Scan image') {
            sh '/var/jenkins_home/app/run_cbctl.sh'
            sh '/var/jenkins_home/app/cbctl image scan ${REPO}/${IMAGE} -o json >> ${BUILD_NUMBER_SCAN_OUTFILE}'
            slackUploadFile filePath: "${BUILD_NUMBER_SCAN_OUTFILE}", initialComment: "Scan results for [Jenkins] '${env.JOB_NAME}' ${env.BUILD_URL}"
        }

        stage('Validate image') {
            try {
                echo "Starting validate test for ${REPO}/${IMAGE}. If there are issues, review ${REPO}_${IMAGE}_validate.json"
                sh '/var/jenkins_home/app/cbctl image validate ${REPO}/${IMAGE} -o json >> ${REPO}_${IMAGE}_validate.json'
            } 
            catch (err) { 
                echo "Build failed. Review Cbctl scan results." 
                slackUploadFile filePath: "${REPO}_${IMAGE}_validate.json", initialComment: "Validate results for {Jenkins] '${env.JOB_NAME}' ${env.BUILD_URL}" 
            }
        }
    }

    stage('Push image') {
        /* 
			You would need to first register with DockerHub before you can push images to your account
		*/
        docker.withRegistry('https://registry.hub.docker.com', 'docker-hub') {
            app.push("${env.BUILD_NUMBER}")
            app.push("latest")
            } 
                echo "Trying to Push Docker Build to DockerHub"
    }
}
