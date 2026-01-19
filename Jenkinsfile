pipeline {
  agent any

  environment {
    IMAGE = "samihannandedkar/node-cicd-app"
    CLUSTER = "jenkins-cluster"
  }

  stages {

    stage('Checkout') {
      steps {
        git branch: 'main',
            url: 'https://github.com/Samihan15/jenkins-cicd.git'
      }
    }

    stage('Build Image') {
      steps {
        sh "docker build -t $IMAGE:latest app"
      }
    }

    stage('Security Scan') {
      steps {
        sh "trivy image --severity CRITICAL,HIGH $IMAGE:latest"
      }
    }

    stage('Login & Push') {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'docker-access',
          usernameVariable: 'DOCKER_USER',
          passwordVariable: 'DOCKER_PASS'
        )]) {
          sh """
            echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin
            docker push $IMAGE:latest
          """
        }
      }
    }

    stage('Create Cluster') {
      steps {
        sh '''
        kind delete cluster --name jenkins-cluster || true
        kind create cluster --name jenkins-cluster --config kind-config.yml
        '''
      }
    }

    stage('Install Ingress Controller') {
      steps {
        sh '''
        kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
        kubectl wait --namespace ingress-nginx \
          --for=condition=ready pod \
          --selector=app.kubernetes.io/component=controller \
          --timeout=180s
        '''
      }
    }

    stage('Load Image to Cluster') {
      steps {
        sh "kind load docker-image $IMAGE:latest --name $CLUSTER"
      }
    }

    stage('Deploy App') {
      steps {
        sh '''
        kubectl apply -f secret.yml
        kubectl apply -f deployment.yml
        kubectl apply -f service.yml
        kubectl apply -f ingress.yml
        kubectl rollout status deployment node-app
        '''
      }
    }
  }
}
