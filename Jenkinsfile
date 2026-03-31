pipeline {
    agent any

    environment {
        AWS_REGION = 'us-west-2'
        ECR_REPO = '472981659331.dkr.ecr.us-west-2.amazonaws.com/ecs-cicd-app'
        IMAGE_TAG = "${BUILD_NUMBER}" // unique per build
        CLUSTER_NAME = 'ecs-cluster'
        SERVICE_NAME = 'ecs-service'
        TASK_DEFINITION = 'ecs-task-def'
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
                sh """
                docker build -t ecs-cicd-app:${IMAGE_TAG} .
                docker tag ecs-cicd-app:${IMAGE_TAG} ${ECR_REPO}:${IMAGE_TAG}
                """
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    sh """
                    aws ecr get-login-password --region ${AWS_REGION} | docker login --username AWS --password-stdin ${ECR_REPO}
                    docker push ${ECR_REPO}:${IMAGE_TAG}
                    """
                }
            }
        }

        stage('Deploy to ECS') {
            steps {
                script {
                    echo "Deploying ECS service with image tag: ${IMAGE_TAG}"

                    // 1. Get current task definition
                    sh "aws ecs describe-task-definition --task-definition ${TASK_DEFINITION} > taskdef.json"

                    // 2. Update container image in task definition
                    sh """
                    jq --arg IMAGE "${ECR_REPO}:${IMAGE_TAG}" '.taskDefinition.containerDefinitions[0].image = \$IMAGE' taskdef.json > new-taskdef.json
                    """

                    // 3. Register new revision
                    sh "aws ecs register-task-definition --cli-input-json file://new-taskdef.json > taskdef_response.json"

                    // 4. Get new task definition ARN
                    sh "NEW_REVISION=\$(jq -r '.taskDefinition.taskDefinitionArn' taskdef_response.json)"
                    sh "echo New revision: \$NEW_REVISION"

                    // 5. Update ECS service to use new revision
                    sh "aws ecs update-service --cluster ${CLUSTER_NAME} --service ${SERVICE_NAME} --task-definition \$NEW_REVISION --force-new-deployment --region ${AWS_REGION}"
                }
            }
        }
    }
}