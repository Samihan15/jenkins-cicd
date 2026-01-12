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

        stage('Build and Push Docker Image') {
            steps {
                script {
                    withCredentials([usernamePassword(credentialsId: 'docker-access', usernameVariable: 'DOCKER_USER', passwordVariable: 'DOCKER_PASS')]) {
                        // The credentials are now available as environment variables $DOCKER_USER and $DOCKER_PASS
                        sh '''
                            # Use set +x to prevent the password from being echoed in the console log
                            set +x
                            echo "$DOCKER_PASS" | docker login -u "$DOCKER_USER" --password-stdin
                            set -x
                            docker build -t your_dockerhub_username/your_image_name:latest .
                            docker push your_dockerhub_username/your_image_name:latest
                        '''
                    }
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
