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
                docker build -t ecs-cicd-app:${IMAGE_TAG} \
                  --build-arg APP_VERSION=${IMAGE_TAG} .
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
                script {
                    sh '''
                    set -e

                    echo "Getting current task definition..."
                    TASK_DEF=$(aws ecs describe-task-definition \
                      --task-definition ecs-cicd-app-task \
                      --query taskDefinition)

                    echo "Saving previous revision for rollback..."
                    PREV_TASK_DEF_ARN=$(echo $TASK_DEF | jq -r '.taskDefinitionArn')

                    echo $PREV_TASK_DEF_ARN > prev-task.txt

                    echo "Creating new task definition with updated image..."
                    NEW_TASK_DEF=$(echo "$TASK_DEF" | jq --arg IMAGE "$ECR_REPO:$IMAGE_TAG" '
                    {
                       family: .family,
                       executionRoleArn: .executionRoleArn,
                       networkMode: .networkMode,
                       containerDefinitions: (.containerDefinitions | map(
                         .image = $IMAGE |
                         .environment = [{"name":"APP_VERSION","value":"'"$IMAGE_TAG"'"}]
                       )),
                       requiresCompatibilities: .requiresCompatibilities,
                       cpu: .cpu,
                       memory: .memory
                    }')

                    echo "$NEW_TASK_DEF" > new-task-def.json

                    echo "Registering new task definition..."
                    NEW_TASK_DEF_ARN=$(aws ecs register-task-definition \
                      --cli-input-json file://new-task-def.json \
                      --query 'taskDefinition.taskDefinitionArn' \
                      --output text)

                    echo $NEW_TASK_DEF_ARN > new-task.txt

                    echo "Updating ECS service..."
                    aws ecs update-service \
                      --cluster $CLUSTER \
                      --service $SERVICE \
                      --task-definition $NEW_TASK_DEF_ARN \
                      --region $AWS_REGION

                    echo "Waiting for ECS to stabilize (max 3 mins)..."
                    timeout 180s aws ecs wait services-stable \
                      --cluster $CLUSTER \
                      --services $SERVICE \
                      --region $AWS_REGION || echo "Not fully stable, continuing..."
                    '''
                }
            }
        }

        stage('Health Check') {
            steps {
                script {
                    sh '''
                    set -e
                    echo "Waiting for ECS service to stabilize (max 3 mins)..."

                    if ! timeout 180s aws ecs wait services-stable \
                      --cluster $CLUSTER \
                      --services $SERVICE \
                      --region $AWS_REGION; then
                      echo "ECS did not stabilize within 3 mins"
                      exit 1
                    fi

                    echo "ECS service is stable"

                    RUNNING_COUNT=$(aws ecs describe-services \
                      --cluster $CLUSTER \
                      --services $SERVICE \
                      --query "services[0].runningCount" \
                      --output text)

                    echo "Running tasks: $RUNNING_COUNT"

                    if [ "$RUNNING_COUNT" -lt "1" ]; then
                      echo "Health check failed!"
                      exit 1
                    fi

                    echo "Health check passed!"
                    '''
                }
            }
        }
    }
    post {
        failure {
            script {
                sh '''
                echo "Deployment failed. Rolling back..."

                PREV_TASK_DEF_ARN=$(cat prev-task.txt)

                aws ecs update-service \
                  --cluster $CLUSTER \
                  --service $SERVICE \
                  --task-definition $PREV_TASK_DEF_ARN \
                  --region $AWS_REGION
                '''
            }
        }
    }
}