# NodeApp

Demo repo which can be used to test the first few stages of a CI pipeline and include cbctl validate and scan results.

Jenkins-docker server configuration steps can be found here: https://github.com/JaBarosin/jenkins

Slack configuration steps: https://plugins.jenkins.io/slack/#bot-user-mode

Here is the snipit of the stage that is used to run cbctl:
    Note: cbctl_validate_helper.py can be found in the above jenkins repo inside the 'app' folder
```
    - stage('Validate image') {
            try {
                echo "Starting validate test for ${REPO}/${IMAGE}. If there are issues, review ${REPO}_${IMAGE}_validate.json"
                sh '/var/jenkins_home/app/cbctl image validate ${REPO}/${IMAGE} -o json > ${REPO}_${IMAGE}_validate.json'
		sh 'python3 /var/jenkins_home/app/cbctl_validate_helper.py ${REPO}_${IMAGE}_validate.json > slack_block.txt' 
                // slackSend color: "good", message: "No violations! Woohoo! [Jenkins] '${env.JOB_NAME}' ${env.BUILD_URL}"  
                
                slackSend(channel: "#build-alerts", blocks: blocks)
            } 
            catch (err) { 
                echo "Build detected cbctl violations. Review Cbctl scan results." 
                sh 'python3 /var/jenkins_home/app/cbctl_validate_helper.py ${REPO}_${IMAGE}_validate.json > slack_block.txt'
```

