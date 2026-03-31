pipeline {
    agent any

    environment {
        AWS_REGION = 'us-west-2'
        ECR_REPO = '472981659331.dkr.ecr.us-west-2.amazonaws.com/ecs-cicd-app'
        IMAGE_TAG = "${BUILD_NUMBER}"  // unique version per build
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
                sh """
                docker build -t ecs-cicd-app:${IMAGE_TAG} .
                """
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    echo "Pushing Docker image to ECR with version: ${IMAGE_TAG}"
                    sh """
                    # Authenticate to ECR
                    aws ecr get-login-password --region $AWS_REGION | \
                    docker login --username AWS --password-stdin $ECR_REPO

                    # Tag and push versioned image
                    docker tag ecs-cicd-app:${IMAGE_TAG} $ECR_REPO:${IMAGE_TAG}
                    docker push $ECR_REPO:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
                script {
                    echo "Deploying ECS service with image tag: ${IMAGE_TAG}"

                    sh """
                    # Update ECS task definition dynamically
                    # taskdef.json is your template ECS task definition
                    TASK_DEF_ARN=$(aws ecs register-task-definition \
                        --cli-input-json file://taskdef.json \
                        --query 'taskDefinition.taskDefinitionArn' \
                        --output text)

                    # Update ECS service to use new task definition
                    aws ecs update-service \
                        --cluster ecs-cluster \
                        --service ecs-service \
                        --task-definition $TASK_DEF_ARN \
                        --force-new-deployment \
                        --region $AWS_REGION
                    """
                }
            }
        }
    }

    post {
        success {
            echo "Deployment completed successfully for build ${BUILD_NUMBER}"
        }
        failure {
            echo "Deployment failed for build ${BUILD_NUMBER}"
        }
    }
}