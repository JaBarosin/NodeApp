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
            echo "Current build lookin: ${currentBuild.currentResult}"
        }
    }
    
    withEnv(["BUILD_NUMBER_SCAN_OUTFILE=cbctl_scan_${currentBuild.number}.json", "REPO=jbarosin", "IMAGE=nodeapp"]){
        
        blocks = [
	[
		"type": "section",
		"text": [
			"type": "mrkdwn",
			"text": "Hello, Assistant to the Regional Manager Dwight! *Michael Scott* wants to know where you'd like to take the Paper Company investors to dinner tonight.\n\n *Please select a restaurant:*"
		]
	],
    [
		"type": "divider"
	],
	[
		"type": "section",
		"text": [
			"type": "mrkdwn",
			"text": "*Farmhouse Thai Cuisine*\n:star::star::star::star: 1528 reviews\n They do have some vegan options, like the roti and curry, plus they have a ton of salad stuff and noodles can be ordered without meat!! They have something for everyone here"
		],
		"accessory": [
			"type": "image",
			"image_url": "https://s3-media3.fl.yelpcdn.com/bphoto/c7ed05m9lC2EmA3Aruue7A/o.jpg",
			"alt_text": "alt text for image"
		]
	]
] 
    
        stage('Validate image') {
            try {
                echo "Starting validate test for ${REPO}/${IMAGE}. If there are issues, review ${REPO}_${IMAGE}_validate.json"
                sh '/var/jenkins_home/app/cbctl image validate hello-world -o json >> ${REPO}_${IMAGE}_validate.json'
                slackSend color: "good", message: "No violations! Woohoo! [Jenkins] '${env.JOB_NAME}' ${env.BUILD_URL}"  
                slackSend(channel: "#build-alerts", blocks: blocks)
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
            app.push("latest")
            } 
                echo "Trying to Push Docker Build to DockerHub"
    }
}
