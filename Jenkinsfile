pipeline {
  agent any

  environment {
    IMAGE = "samihannandedkar/node-cicd-app"
    CLUSTER = "jenkins-cluster"
    NAMESPACE = "demo"
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
        sh "trivy image --severity CRITICAL,HIGH $IMAGE:latest"
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
        '''
      }
    }

    stage('Install Ingress Controller') {
      steps {
        sh '''
        kubectl apply --validate=false -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml || true
        kubectl wait --namespace ingress-nginx \
          --for=condition=ready pod \
          --selector=app.kubernetes.io/component=controller \
          --timeout=180s || true
        '''
      }
    }

    stage('Load Image into Kind') {
      steps {
        sh "kind load docker-image $IMAGE:latest --name $CLUSTER"
      }
    }

    stage('Deploy Application') {
      steps {
        sh '''
        kubectl apply -f namespace.yml
        kubectl apply -f secret.yml -n $NAMESPACE
        kubectl apply -f deployment.yml
        kubectl apply -f service.yml
        kubectl apply -f ingress.yml
        kubectl rollout status deployment node-app -n $NAMESPACE --timeout=120s
        '''
      }
    }

    stage('Show Demo Output') {
      steps {
        sh '''
        echo "================================="
        echo "DEPLOYMENT SUCCESSFUL"
        echo "================================="
        kubectl get all -n $NAMESPACE
        kubectl get ingress -n $NAMESPACE
        '''
      }
    }
  }
}
