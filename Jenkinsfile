pipeline {
    agent any

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/sathwiksharmabs/ecs-cicd-pipeline.git'
            }
        }

        stage('Fix Permissions') {
            steps {
                sh 'chmod +x mvnw'
            }
        }

        stage('Build') {
            steps {
                sh './mvnw clean package'
            }
        }

        stage('Test') {
            steps {
                sh './mvnw test'
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                docker build -t ecs-cicd-app:${BUILD_NUMBER} .
                docker tag ecs-cicd-app:${BUILD_NUMBER} ecs-cicd-app:latest
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region us-west-2 | \
                docker login --username AWS --password-stdin 472981659331.dkr.ecr.us-west-2.amazonaws.com
                docker tag ecs-cicd-app:${BUILD_NUMBER} 472981659331.dkr.ecr.us-west-2.amazonaws.com/ecs-cicd-app:${BUILD_NUMBER}
                docker push 472981659331.dkr.ecr.us-west-2.amazonaws.com/ecs-cicd-app:${BUILD_NUMBER}
                '''
            }
        }
    }
}