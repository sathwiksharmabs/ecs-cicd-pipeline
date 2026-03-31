pipeline {
    agent any

    environment {
    AWS_REGION = 'us-west-2'
    ECR_REPO = '472981659331.dkr.ecr.us-west-2.amazonaws.com/ecs-cicd-app'
    }

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
                aws ecr get-login-password --region $AWS_REGION | \
                docker login --username AWS --password-stdin $ECR_REPO

                docker tag ecs-cicd-app:${BUILD_NUMBER} $ECR_REPO:${BUILD_NUMBER}
                docker tag ecs-cicd-app:${BUILD_NUMBER} $ECR_REPO:latest

                docker push $ECR_REPO:${BUILD_NUMBER}
                docker push $ECR_REPO:latest
                '''
            }
        }
        
    }
}