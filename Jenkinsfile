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

        stage('Docker Build') {
            steps {
                sh "docker build -t $IMAGE:latest app"
            }
        }

        stage('Trivy Scan') {
            steps {
                sh "trivy image --severity CRITICAL,HIGH $IMAGE:latest"
            }
        }

        stage('Docker Login') {
            steps {
                withCredentials([usernamePassword(
                    credentialsId: 'docker-access',
                    usernameVariable: 'DOCKER_USER',
                    passwordVariable: 'DOCKER_PASS'
                )]) {
                    sh "echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin"
                }
            }
        }

        stage('Docker Push') {
            steps {
                sh "docker push $IMAGE:latest"
            }
        }

        stage('Create Kind Cluster') {
            steps {
                sh '''
                kind get clusters | grep $CLUSTER || kind create cluster --name $CLUSTER
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
                kubectl apply -f deployment.yml
                kubectl apply -f service.yml
                kubectl rollout status deployment node-app
                '''
            }
        }
    }
}
