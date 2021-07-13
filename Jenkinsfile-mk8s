node {

  stage('Get deployment files') {
      /* Cloning the Repository to jenkins-docker Workspace */
      // git branch: 'jake-testing', url: 'https://github.com/JaBarosin/NodeApp.git'
      checkout scm
  }


  stage('Deploy to mK8s') {
    sshagent(['ubuntu-host']) {
      sh "scp -o StrictHostKeyChecking=no pod-v1.yaml jake@192.168.6.44:/k8s/dev/"
      try{
          sh "ssh jake@192.168.6.44 kubectl apply -f ."
      }

      catch(error){
          echo "Welp... those didnt exist yet"
          sh "ssh jake@192.168.6.44 kubectl create -f ."
      }
    }

  }

}
