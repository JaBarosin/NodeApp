node {
    def app

    /* Default to no violations. Used to specify whether no violations vs. violations
    message is sent. */
    violations = false

    stage('Clone repository') {
        /* Cloning the Repository to jenkins-docker Workspace */

        checkout scm
    }

    withEnv([
        "BUILD_NUMBER_SCAN_OUTFILE=cbctl_scan_${currentBuild.number}.json",
        "REPO=jbarosin",
        "IMAGE=nodeapp",
        "CBCTL_RESULTS=testing"]){

      /*
         Environment variables:
          BUILD_NUMBER_SCAN_OUTFILE = json output from 'cbctl validate'
          REPO = currently my public docker repo
          IMAGE = name assigned to image in the Build stage
          CBCTL_RESULTS = place holder variable. Currently sent in the slack block
                          when there are no violations during 'cbctl validate'
      */


    stage('Build image') {
      /*
         Build stage.  Build statically defined image name.
      */
        app = docker.build("${REPO}/${IMAGE}")
    }


    stage('Test image') {
      /*
         Test stage.  Not much to see here...
      */

        app.inside {
            echo "Tests passed"
            echo "Current build lookin: ${currentBuild.currentResult}"
        }
    }


    stage('Push image') {
        /*
    			Docker credentials need to be setup in Jenkins.
          Make sure that "docker-hub" is the name of the credential ID for your
          docker account in Jenkins, or modify it accordingly.
    		*/
            docker.withRegistry('https://registry.hub.docker.com', 'docker-hub') {
                app.push("latest")
                }
                    echo "Trying to Push Docker Build to DockerHub"
      }

    // withEnv(["BUILD_NUMBER_SCAN_OUTFILE=cbctl_scan_${currentBuild.number}.json", "REPO=jbarosin", "IMAGE=nodeapp", "CBCTL_RESULTS=testing"]){

    /*
        This builds the slack blocks for sending success/failed cbctl validate results.
    */

    // blocks = [
	  //       [
    //     	 "type": "section",
    //        "text": [
    //                   	"type": "mrkdwn",
    //                    	"text": "*CBCTL Validate results* - No build violations\n<https://defense-prod05.conferdeploy.net/kubernetes/repos|Review related image in CBC Console>"
    //            		 ]
	  //       ],
    //
    // 	    [
    //             "type": "divider"
    //       ],
    //
    //      [
    //       "type": "section",
   	//       "text": [
    //             	 "type": "mrkdwn",
    //                "text": "${env.JOB_NAME} - ${CBCTL_RESULTS}"
	  //              	]
    //      ]
    // ]

    /*
        Validate new build with cbctl. Outfiles written include the ${IMAGE}_${NAME}_validate.json and the cbctl_policy_violations.txt
        Tries to validate and send confirmation of no violations.
        Catch cbctl error when violations occur and send offending rules to cbctl_policy_violations.txt for upload. File is uploaded currently but ideally i want to show the
        rules in the slack message.
    */

      stage('Validate image') {
          try {
              echo "Validate stage... Starting validate test for ${REPO}/${IMAGE}. If there are issues, review ${REPO}_${IMAGE}_validate.json"
              sh '/var/jenkins_home/app/cbctl image validate ${REPO}/${IMAGE} -o json > ${REPO}_${IMAGE}_validate.json'
	            sh 'python3 /var/jenkins_home/app/cbctl_validate_helper.py ${REPO}_${IMAGE}_validate.json > cbctl_policy_no_violations_${env.JOB_NUMBER}.txt'

              // slackSend color: "good", message: "No violations! Woohoo! [Jenkins] '${env.JOB_NAME}' ${env.BUILD_URL}"
              // slackSend(channel: "#build-alerts", blocks: blocks)
          }
          catch (err) {
              echo "Build detected cbctl violations. Review Cbctl scan results."
              sh 'python3 /var/jenkins_home/app/cbctl_validate_helper.py ${REPO}_${IMAGE}_validate.json > cbctl_policy_violations_${env.JOB_NUMBER}.txt'

              // SLACK_CBCTL = sh 'cat slack_block.txt'
              // echo "Message to send in slack_block: ${SLACK_CBCTL}"
              // blocks_fail = [
              //         [
              //          "type": "section",
              //          "text": [
              //                 "type": "mrkdwn",
              //                 "text": "*CBCTL Validate results* - Build violations detected\n<https://defense-prod05.conferdeploy.net/kubernetes/repos|Review related image in CBC Console>"
              //                 ]
              //         ],
              //
              //     [
              //         "type": "divider"
              //     ],
              //
              //     [
              //         "type": "section",
              //         "text": [
              //                 "type": "mrkdwn",
              //                 "text": "${env.JOB_NAME} -  ${SLACK_CBCTL}"
              //             ]
              //     ]
              //  ]

             //  slackUploadFile filePath: "${REPO}_${IMAGE}_validate.json", initialComment: "Validate results for [Jenkins] '${env.JOB_NAME}' ${env.BUILD_URL}"

             // slackSend(channel: "#build-alerts", blocks: blocks_fail)
             // slackUploadFile filePath: "slack_block.txt", initialComment: ""
	           // echo "results of cbctl validate can be found in ${REPO}/${IMAGE}_validate.json and a summary in 'slack_block.txt'"
           }
        }

        /*
          Creates slack block messages and uploads violation summary to channel.
        */

        stage('Send Validate Results') {

          SLACK_CBCTL = sh 'cat slack_block.txt'
          echo "Message to send in slack_block: ${SLACK_CBCTL}"
          blocks_fail = [
                  [
                   "type": "section",
                   "text": [
                          "type": "mrkdwn",
                          "text": "*CBCTL Validate results* - \n<https://defense-prod05.conferdeploy.net/kubernetes/repos|Review related image in CBC Console>"
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

          if(violations == false) {
            slackSend color: "good", message: "No violations! Woohoo! [Jenkins] '${env.JOB_NAME}' ${env.BUILD_URL}"

          }

          if(violations == true) {
            slackSend(channel: "#build-alerts", blocks: blocks_fail)
            slackUploadFile filePath: "cbctl_policy_violations_${env.JOB_NUMBER}.txt", initialComment: ""
            echo "Violations occured. results of cbctl validate can be found in ${REPO}/${IMAGE}_validate.json and a summary in 'slack_block.txt'"


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
