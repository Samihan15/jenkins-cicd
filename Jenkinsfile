pipeline {
  agent any

  environment {
    IMAGE = "samihannandedkar/node-devops-app"
    SCANNER_HOME = tool 'sonar-scanner'
  }

  stages {

    stage("Checkout") {
      steps {
        git branch: 'main',
        url: 'https://github.com/Samihan15/jenkins-cicd.git'
      }
    }

    stage("SonarQube Analysis") {
      steps {
        withSonarQubeEnv('sonarqube-server') {
          sh """
            ${SCANNER_HOME}/bin/sonar-scanner \
            -Dsonar.projectKey=node-devops-app \
            -Dsonar.sources=app
          """
        }
      }
    }

    stage("Docker Build") {
      steps {
        sh """
          docker build -t ${IMAGE}:latest -f docker/Dockerfile .
        """
      }
    }

    stage("Trivy Scan") {
      steps {
        sh """
          trivy image --severity HIGH,CRITICAL ${IMAGE}:latest
        """
      }
    }

    stage("Docker Push") {
      steps {
        withCredentials([usernamePassword(
          credentialsId: 'dockerhub-creds',
          usernameVariable: 'DOCKER_USER',
          passwordVariable: 'DOCKER_PASS'
        )]) {
          sh """
            echo \$DOCKER_PASS | docker login -u \$DOCKER_USER --password-stdin
            docker push ${IMAGE}:latest
          """
        }
      }
    }

    stage("Deploy to Kubernetes") {
      steps {
        sh """
          kubectl apply -f k8s/
          kubectl rollout status deployment/node-app
        """
      }
    }
  }

  post {
    success {
      echo "CI/CD Pipeline executed successfully"
    }
    failure {
      echo "Pipeline failed – check logs"
    }
  }
}
