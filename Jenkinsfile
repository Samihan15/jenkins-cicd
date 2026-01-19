pipeline {
  agent any

  environment {
    IMAGE = "samihannandedkar/node-cicd-app"
    CLUSTER = "jenkins-demo"
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

    stage('Security Scan (Trivy)') {
      steps {
        sh "trivy image --severity CRITICAL,HIGH $IMAGE:latest || true"
      }
    }

    stage('Docker Login & Push') {
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

    stage('Create Kind Cluster') {
      steps {
        sh '''
        kind delete cluster --name $CLUSTER || true
        kind create cluster --name $CLUSTER

        mkdir -p ~/.kube
        kind get kubeconfig --name $CLUSTER > ~/.kube/config

        echo "Waiting for cluster to be ready..."
        sleep 30
        '''
      }
    }

    stage('Load Image to Kind') {
      steps {
        sh "kind load docker-image $IMAGE:latest --name $CLUSTER"
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

    stage('Demo Proof') {
      steps {
        sh '''
        echo "=============================="
        echo "DEPLOYMENT SUCCESSFUL"
        echo "=============================="
        kubectl get pods
        kubectl get svc
        '''
      }
    }
  }
}
