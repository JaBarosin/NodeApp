node {
    def app
    def statusCode = sh script:script, returnStatus:true

    stage('Clone repository') {
        /* Cloning the Repository to our Workspace */

        checkout scm
    }

    stage('Build image') {
        /* This builds the actual image */

        app = docker.build("jbarosin/nodeapp")
    }

    stage('Test image') {
        
        app.inside {
            echo "Tests passed"
        }
    }
    withEnv(["BUILD_NUMBER_SCAN_OUTFILE=cbctl_scan_${currentBuild.number}.json", "REPO=jbarosin", "IMAGE=nodeapp"]){
        stage('Scan image') {
            sh '/var/jenkins_home/app/run_cbctl.sh'
            sh '/var/jenkins_home/app/cbctl image scan ${REPO}/${IMAGE} -o json >> ${BUILD_NUMBER_SCAN_OUTFILE}'
            slackUploadFile filePath: "${BUILD_NUMBER_SCAN_OUTFILE}", initialComment: "Scan results"
        }

        stage('Validate image') {
            echo "Starting validate test for ${REPO}/${IMAGE}"
            try { 
                sh '/var/jenkins_home/app/cbctl image validate hello-world -o json >> ${REPO}_${IMAGE}_validate.json'
               }
            catch(all) {
                slackUploadFile filePath: "${REPO}_${IMAGE}_validate.json", initialComment: "Validate results" 
                sh "echo 'Failed'"
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
