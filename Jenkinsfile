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
                sh """
                docker build -t ecs-cicd-app:${IMAGE_TAG} .
                docker tag ecs-cicd-app:${IMAGE_TAG} ecs-cicd-app:latest
                """
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    echo "Pushing Docker image to ECR with version: ${BUILD_NUMBER}"
                    sh """
                    aws ecr get-login-password --region $AWS_REGION | \
                    docker login --username AWS --password-stdin $ECR_REPO

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

                    // 1. Fetch current task definition JSON
                    sh """
                    aws ecs describe-task-definition --task-definition ecs-task-def > taskdef.json
                    """

                    // 2. Replace image in container definitions
                    sh """
                    cat taskdef.json | jq '.taskDefinition.containerDefinitions[0].image = "${ECR_REPO}:${IMAGE_TAG}"' > new-taskdef.json
                    """

                    // 3. Register new task definition revision
                    sh """
                    aws ecs register-task-definition \
                        --cli-input-json file://new-taskdef.json > taskdef_response.json
                    """

                    // 4. Get new revision ARN
                    sh """
                    NEW_REVISION=\$(cat taskdef_response.json | jq -r '.taskDefinition.taskDefinitionArn')
                    echo "New revision ARN: \$NEW_REVISION"
                    """

                    // 5. Update ECS service to use new revision
                    sh """
                    aws ecs update-service \
                        --cluster ecs-cluster \
                        --service ecs-service \
                        --task-definition \$NEW_REVISION \
                        --force-new-deployment \
                        --region $AWS_REGION
                    """
                }
            }
        }
    }
}