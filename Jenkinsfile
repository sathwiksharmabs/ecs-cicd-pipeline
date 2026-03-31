pipeline { 
    agent any

    environment {
        AWS_REGION = 'us-west-2'
        ECR_REPO = '472981659331.dkr.ecr.us-west-2.amazonaws.com/ecs-cicd-app'
        IMAGE_TAG = "${BUILD_NUMBER}" // unique for each build
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/sathwiksharmabs/ecs-cicd-pipeline.git'
            }
        }

        stage('Fix Permissions') {
            steps {
                sh 'chmod +x mvnw deploy.sh'
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
                docker build -t ecs-cicd-app:${IMAGE_TAG} .
                docker tag ecs-cicd-app:${IMAGE_TAG} ecs-cicd-app:latest
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region $AWS_REGION | \
                docker login --username AWS --password-stdin $ECR_REPO

                docker tag ecs-cicd-app:${IMAGE_TAG} $ECR_REPO:${IMAGE_TAG}
                docker tag ecs-cicd-app:${IMAGE_TAG} $ECR_REPO:latest

                docker push $ECR_REPO:${IMAGE_TAG}
                docker push $ECR_REPO:latest
                '''
            }
        }

        stage('Deploy to ECS') {
            steps {
                sh './deploy.sh $IMAGE_TAG'
            }
        }
        
    }
}