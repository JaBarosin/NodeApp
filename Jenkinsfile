node {
    def app
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
    withEnv(["BUILD_NUMBER_SCAN_OUTFILE=cbctl_scan_${currentBuild.number}.json"]){
        stage('Scan image') {
            sh '/var/jenkins_home/app/run_cbctl.sh'
            sh '/var/jenkins_home/app/cbctl image scan jbarosin/nodeapp -o json >> /var/jenkins_home/app/logs/${BUILD_NUMBER_SCAN_OUTFILE}'
            slackUploadFile filePath: "/var/jenkins_home/app/logs/${BUILD_NUMBER_SCAN_OUTFILE}, initialComment: "Build scan results"
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
