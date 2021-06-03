# NodeApp

Hey y'all! This is a Demo repo which can be used to get started and test the first few stages of a CI pipeline and include cbctl validate + scan results.

The **Jenkins-docker** server configuration steps can be found here: https://github.com/JaBarosin/jenkins

I used Slack for my first tests, but plugins to logstash, jira, or wherever you'd like to send a message to should be easy enough to add.  Here are the Slack configuration steps if interested: https://plugins.jenkins.io/slack/#bot-user-mode

Here is a snipit of the stage that is used to run cbctl:

Note: cbctl_validate_helper.py can be found in the above jenkins repo inside the 'app' folder

```
stage('Validate image') {
    try {
        echo "Validate stage... Starting validate test for ${REPO}/${IMAGE}. If there are issues, review ${REPO}_${IMAGE}_validate.json"
        sh '/var/jenkins_home/app/cbctl image validate ${REPO}/${IMAGE} -o json > ${REPO}_${IMAGE}_validate.json'
        sh 'python3 /var/jenkins_home/app/cbctl_validate_helper.py ${REPO}_${IMAGE}_validate.json > cbctl_policy_no_violations.txt'


    }
    catch (err) {
        violations = true
        echo "Build detected cbctl violations. Review Cbctl scan results."
        sh 'python3 /var/jenkins_home/app/cbctl_validate_helper.py ${REPO}_${IMAGE}_validate.json > cbctl_policy_violations.txt'

     }
  }
```
