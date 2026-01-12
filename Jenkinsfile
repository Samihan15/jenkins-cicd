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
                bat "trivy image --severity CRITICAL --exit-code 1 samihannandedkar/node-cicd-app:latest"
            }
        }

        stage('Docker Login') {
    steps {
        withCredentials([usernamePassword(
            credentialsId: 'docker-access',
            usernameVariable: 'DOCKER_USER',
            passwordVariable: 'DOCKER_PASS'
        )]) {
            bat '''
            set PASSWORD=%DOCKER_PASS%
            echo %PASSWORD%>pass.txt
            docker login -u %DOCKER_USER% --password-stdin < pass.txt
            del pass.txt
            '''
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
