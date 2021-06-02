node {
    def app

    stage('Clone repository') {
        /* Cloning the Repository to jenkins-docker Workspace */

        checkout scm
    }

    /*
       Build stage.  Build statically defined image name.
    */
    stage('Build image') {
        /* This builds the actual image */

        app = docker.build("jbarosin/nodeapp")
    }

    /*
       Test stage.  Not much to see here...
    */

    stage('Test image') {

        app.inside {
            echo "Tests passed"
            echo "Current build lookin: ${currentBuild.currentResult}"
        }
    }

    /*
        Push new build to docker hub
    */

    stage('Push image') {
            /*
    			You would need to first register with DockerHub before you can push images to your account
    		*/
            docker.withRegistry('https://registry.hub.docker.com', 'docker-hub') {
                app.push("latest")
                }
                    echo "Trying to Push Docker Build to DockerHub"
      }

    withEnv(["BUILD_NUMBER_SCAN_OUTFILE=cbctl_scan_${currentBuild.number}.json", "REPO=jbarosin", "IMAGE=nodeapp", "CBCTL_RESULTS=testing"]){

    /*
        This builds the slack blocks for sending success/failed cbctl validate results.
    */

    blocks = [
	        [
        	 "type": "section",
           	 "text": [
                      	"type": "mrkdwn",
                       	"text": "*CBCTL Validate results* - No build violations\n<https://defense-prod05.conferdeploy.net/kubernetes/repos|Review related image in CBC Console>"
               		]
	        ],

    	[
                "type": "divider"
        ],

        [
                "type": "section",
         	"text": [
                	 "type": "mrkdwn",
                     	 "text": "${env.JOB_NAME} - ${CBCTL_RESULTS}"
	               	]
        ]
    ]

    /*
        Validate new build with cbctl. Outfiles written include the image_name_validate.json and the slack_block.txt
        Try to validate and send confirmation of no violations.

        Catch cbctl error and send offending rules to slack_block.txt. File is uploaded currently but ideally i want to show the
        rules in the slack message.
    */

        stage('Validate image') {
            try {
                echo "Validate stage... Starting validate test for ${REPO}/${IMAGE}. If there are issues, review ${REPO}_${IMAGE}_validate.json"
                sh '/var/jenkins_home/app/cbctl image validate ${REPO}/${IMAGE} -o json > ${REPO}_${IMAGE}_validate.json'
		            sh 'python3 /var/jenkins_home/app/cbctl_validate_helper.py ${REPO}_${IMAGE}_validate.json > slack_block.txt'

                slackSend color: "good", message: "No violations! Woohoo! [Jenkins] '${env.JOB_NAME}' ${env.BUILD_URL}"
                // slackSend(channel: "#build-alerts", blocks: blocks)
            }
            catch (err) {
                echo "Build detected cbctl violations. Review Cbctl scan results."
                sh 'python3 /var/jenkins_home/app/cbctl_validate_helper.py ${REPO}_${IMAGE}_validate.json > slack_block.txt'

                SLACK_CBCTL = sh 'cat slack_block.txt'
                echo "Message to send in slack_block: ${SLACK_CBCTL}"
                blocks_fail = [
                        [
                         "type": "section",
                         "text": [
                                "type": "mrkdwn",
                                "text": "*CBCTL Validate results* - Build violations detected\n<https://defense-prod05.conferdeploy.net/kubernetes/repos|Review related image in CBC Console>"
                                ]
                        ],

                    [
                        "type": "divider"
                    ],

                    [
                        "type": "section",
                        "text": [
                                "type": "mrkdwn",
                                "text": "${env.JOB_NAME} -  ${SLACK_CBCTL}"
                            ]
                    ]
                 ]

               //  slackUploadFile filePath: "${REPO}_${IMAGE}_validate.json", initialComment: "Validate results for [Jenkins] '${env.JOB_NAME}' ${env.BUILD_URL}"

               slackSend(channel: "#build-alerts", blocks: blocks_fail)
               slackUploadFile filePath: "slack_block.txt", initialComment: ""
		           echo "results of cbctl validate can be found in ${REPO}/${IMAGE}_validate.json and a summary in 'slack_block.txt'"
             }
        }
    }

/* testing remote deployment to microk8s

    stage('Deploy to Microk8s') {
       echo "Deploying to microk8s on dev host"
       sh 'ssh -tt 192.168.6.44'
       sh 'microk8s.kubectl apply -f /opt/k8s/NodeApp/deployment.yaml'
       sh 'exit'
  }

*/

}
