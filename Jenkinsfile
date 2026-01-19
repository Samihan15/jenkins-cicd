pipeline {
  agent any

  environment {
    IMAGE = "samihannandedkar/node-cicd-app"
  }

  stages {

    stage('Checkout') {
      steps {
        git branch: 'main',
            url: 'https://github.com/Samihan15/jenkins-cicd.git'
      }
    }

    stage('Build Docker Image') {
      steps {
        sh "docker build -t $IMAGE:latest app"
      }
    }

    stage('Security Scan') {
      steps {
        sh "trivy image --severity CRITICAL,HIGH $IMAGE:latest || true"
      }
    }

    stage('Push Image') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'docker-access',
          usernameVariable: 'DOCKER_USER',
          passwordVariable: 'DOCKER_PASS'
        )]) {
          sh '''
            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
            docker push $IMAGE:latest
          '''
        }
      }
    }

    stage('Deploy to Kubernetes') {
      steps {
        sh '''
        kubectl apply --validate=false -f deployment.yml
        kubectl apply --validate=false -f service.yml
        kubectl rollout status deployment node-app --timeout=120s || true
        '''
      }
    }

    stage('Show Result') {
      steps {
        sh '''
        kubectl get pods
        kubectl get svc
        '''
      }
    }
  }
}
