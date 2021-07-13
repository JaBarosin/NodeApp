node {

  stage('Get deployment files') {
      /* Cloning the Repository to jenkins-docker Workspace */
      // git branch: 'jake-testing', url: 'https://github.com/JaBarosin/NodeApp.git'
      checkout scm
  }


  stage('Deployment test') {
    sshagent(['ubuntu-host']) {
      sh "scp -o StrictHostKeyChecking=no pod-v1.yaml jake@192.168.6.44:/k8s/dev/"
      try{
          sh "ssh jake@192.168.6.44 microk8s kubectl apply -f ."
      }

      catch(error){
          echo "Welp... those didnt exist yet"
          sh "ssh jake@192.168.6.44 microk8s kubectl create -f ."
      }

      stage('Tests') {
        sh "curl 192.168.6.44:30333"
        echo "Done testing"
      }

      stage('Cleanup') {
        sh "ssh jake@192.168.6.44 microk8s kubectl delete pod nodeapp"
        sh "ssh jake@192.168.6.44 microk8s kubectl get all"
        
      }

    }

  }

}
