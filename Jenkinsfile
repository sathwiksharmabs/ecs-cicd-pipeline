pipeline {
    agent any

    environment {
        AWS_REGION = 'us-west-2'
        ECR_REPO = '472981659331.dkr.ecr.us-west-2.amazonaws.com/ecs-cicd-app'
        CLUSTER = 'ecs-cluster'
        SERVICE = 'ecs-service'
        IMAGE_TAG = "${BUILD_NUMBER}"
    }

    stages {

        stage('Checkout') {
            steps {
                git branch: 'main', url: 'https://github.com/sathwiksharmabs/ecs-cicd-pipeline.git'
            }
        }

        stage('Build & Test') {
            steps {
                sh '''
                chmod +x mvnw
                ./mvnw clean package
                ./mvnw test
                '''
            }
        }

        stage('Docker Build') {
            steps {
                sh '''
                docker build -t ecs-cicd-app:${IMAGE_TAG} .
                '''
            }
        }

        stage('Push to ECR') {
            steps {
                sh '''
                aws ecr get-login-password --region $AWS_REGION | \
                docker login --username AWS --password-stdin $ECR_REPO

                docker tag ecs-cicd-app:${IMAGE_TAG} $ECR_REPO:${IMAGE_TAG}
                docker push $ECR_REPO:${IMAGE_TAG}
                '''
            }
        }

        stage('Deploy to ECS') {
            steps {
                sh '''
                TASK_DEF=$(aws ecs describe-task-definition \
                  --task-definition ecs-cicd-app-task \
                  --query taskDefinition)

                NEW_TASK_DEF=$(echo $TASK_DEF | jq \
                  --arg IMAGE "$ECR_REPO:$IMAGE_TAG" \
                  '.containerDefinitions[0].image = $IMAGE')

                echo $NEW_TASK_DEF > new-task-def.json

                aws ecs register-task-definition \
                  --cli-input-json file://new-task-def.json

                aws ecs update-service \
                  --cluster $CLUSTER \
                  --service $SERVICE \
                  --force-new-deployment \
                  --region $AWS_REGION
                '''
            }
        }

        stage('Health Check') {
            steps {
                sh '''
                sleep 30
                aws ecs describe-services \
                  --cluster $CLUSTER \
                  --services $SERVICE \
                  --query "services[0].runningCount"
                '''
            }
        }
    }

    post {
        failure {
            echo "Deployment failed. Rolling back..."

            sh '''
            aws ecs update-service \
              --cluster $CLUSTER \
              --service $SERVICE \
              --force-new-deployment \
              --region $AWS_REGION
            '''
        }
    }
}