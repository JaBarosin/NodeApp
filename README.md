# NodeApp

Hey y'all! This is a Demo repo which can be used to get started and test the stages of a CI pipeline and to demonstrate how CB Container security helps simplify the process of monitoring, alerting, and preventing K8s deployments that violate company policies.

The **Jenkins-docker** server configuration steps can be found here: https://github.com/JaBarosin/jenkins

This demo sends alerts to Slack, but plugins to logstash, jira, or wherever you'd like to send a message to can be substituted.  Here are the Slack configuration steps if interested: https://plugins.jenkins.io/slack/#bot-user-mode

Here is a snipit of the stage that is used to run cbctl:

```
stage('Validate image') {
  try {
    echo "Validate stage... Starting validate test for ${REPO}/${IMAGE}:${TAG}. If there are issues, review ${REPO}_${IMAGE}_validate.json"
    sh '/var/jenkins_home/app/cbctl image validate ${REPO}/${IMAGE}:${TAG} -o json > ${REPO}_${IMAGE}_validate.json'
    sh 'python3 /var/jenkins_home/app/cbctl_validate_helper.py ${REPO}_${IMAGE}_validate.json > cbctl_policy_no_violations.txt'

  }

  catch (err) {
    violations = true
    echo "Build detected cbctl violations. Review Cbctl scan results."
    sh 'python3 /var/jenkins_home/app/cbctl_validate_helper.py ${REPO}_${IMAGE}_validate.json > cbctl_policy_violations.txt'

    }
  }

```
_NOTE: cbctl_validate_helper.py can be found in the above jenkins repo inside the 'app' folder_



### Getting Started

#### Setup Jenkins

Clone and install https://github.com/JaBarosin/jenkins or offical Jenkins docker IMAGE

NOTE: if using the offical Jenkins docker image you will need to create a directory '/var/jenkins_home/app/' and copy the cbctl_validate_helper.py from https://github.com/JaBarosin/jenkins/tree/master/app


**Install additional Jenkins Plugins**
  - Credentials Plugin
  - Docker Pipeline
  - docker-build-step
  - Groovy
  - pipeline
  - Pipeline: Github
  - Pipeline: Github Groovy Libraries
  - Global Slack Notifier Plugin
  - Slack Notification Plugin
  - Slack Upload Plugin
  - SSH Agent Plugin
  - SSH Buld Agents
  - SSH server
  - Workspace Cleanup Plugin

#### Configure key Plugins

##### Docker

_What is it used for?_

This helps enable the pipeline stages that use docker.  In order to push to your own docker repo you will need to add in a username and password for your docker profile.

How to configure:

From your Jenkins console, navigate to "http://<insert-your-jenkins-ip>:8080/credentials/store/system/domain/_/"

Select "Add Credentials"

- Kind: Username with password
- Scope: Global
- ID: ```docker-hub```
- Description: Creds for public docker profile
- Username: ```dockerhub username```
- Password: ```dockerhub password```


### SSH Agent Plugin

_What is it used for?_

This is used to issue kubectl commands within the Pipeline. The pipeline copies the deployment configs from the Jenkins workspace to K8s host /k8s/dev/ directory.

##### How to configure

From your Jenkins console, navigate to "http://<insert-your-jenkins-ip>:8080/credentials/store/system/domain/_/"

Select "Add Credentials"

Kind: SSH Username with private key
Scope: Global
ID: ```identifier for creds``` - i.e. cbc-k8shost, microk8s-dev, another label of your liking
Description: CBC container K8s host
Username: ```ssh username```
Private Key: If already created then copy into Jenkins UI. If no keys in '~/.ssh/' then create a new SSH key. https://phoenixnap.com/kb/generate-setup-ssh-key-ubuntu


### Slack (Notification, Upload, and Global)

_What is it used for?_

The Slack Plugin allows posts of the pipeline build status to be sent.  

The This is used to send build notification to a slack channel as well as upload a summary of the cbctl scan/validate results to the slack channel.

How to configure:

- Navigate to Jenkins Dashboard > Manage Jenkins > Configure System
- Scroll to "Slack" section (likely at the bottom)

Workspace: ```(name of slack workspace to send messages)```
Credentials: ```(select ID of slack creds) This credential is to the bot OAuth Access Token```

Note: If you do not have access to an existing workspace/bot -  https://github.com/jenkinsci/slack-plugin#bot-user-mode

The Slack Upload step is used in the Jenkinsfile to upload the logs from cbctl to the slack channel.  Once the credentials are setup within Jenkins this should be good to go!

**Setup Jenkins Pipeline jobs**

Phase 1 - Docker-Build-pipeline
Phase 2 - Microk8s-Deploy Jobs

---

### Setting up Jenkins Jobs

From Jenkins dashboard

Select ```New Item```
Name: ```Docker-Build-Pipeline```
Select ```Pipeline``` and save
On the Configure Pipeline page Pipeline section:
- Definition: ```Pipeline script from scm```
- SCM: Git
- Repositories - Repository URL: https://github.com/JaBarosin/NodeApp.git
  - Credentials: None
  - Branches to build: master
  - Script Path: Jenkinsfile

##### Deploy Job Setup

Follow **https://github.com/JaBarosin/K8sConfigs/tree/main** for the setup of Phase 2 deployment jobs


**Environment check**
  * Confirm microk8s or other cluster is running on target dev server.
  * Be sure that the directory "/k8s/dev/" exists on the K8s host as that is where the deployment files are copied to from the Jenkins workspace.
  * confirm cbctl is operational on Jenkins docker
    * once copied to Jenkins docker, be sure to apply the cbctl_default configurations.
