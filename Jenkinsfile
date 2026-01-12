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

        stage('Install Dependencies') {
            steps {
                bat 'cd app && npm install'
            }
        }

        stage('Docker Build') {
            steps {
                bat "docker build -t %IMAGE%:latest ."
            }
        }

        stage('Trivy Scan') {
            steps {
                bat "trivy image --ignore-unfixed --severity HIGH,CRITICAL --exit-code 1 samihannandedkar/node-cicd-app:latest
"
            }
        }

        stage('Docker Push') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-access',
                    usernameVariable: 'USER',
                    passwordVariable: 'PASS'
                )]) {
                    bat """
                    echo %PASS% | docker login -u %USER% --password-stdin
                    docker push %IMAGE%:latest
                    """
                }
            }
        }

        stage('Deploy to Minikube') {
            steps {
                bat 'kubectl apply -f k8s/'
            }
        }
    }
}
