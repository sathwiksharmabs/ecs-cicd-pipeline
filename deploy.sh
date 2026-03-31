#!/bin/bash

# Usage: ./deploy.sh <IMAGE_TAG>
IMAGE_TAG=$1
CLUSTER_NAME="ecs-cluster"
SERVICE_NAME="ecs-service"
REGION="us-west-2"
ECR_REPO="472981659331.dkr.ecr.us-west-2.amazonaws.com/ecs-cicd-app"

if [ -z "$IMAGE_TAG" ]; then
  echo "Error: IMAGE_TAG not provided"
  exit 1
fi

echo "Updating ECS service with image tag: $IMAGE_TAG"

# Update ECS task definition with new image
TASK_DEF_JSON=$(aws ecs describe-task-definition \
  --task-definition $SERVICE_NAME \
  --region $REGION)

# Create new task definition revision with updated image
NEW_TASK_DEF=$(echo $TASK_DEF_JSON | jq --arg IMAGE "$ECR_REPO:$IMAGE_TAG" \
'.taskDefinition | .containerDefinitions[0].image=$IMAGE | {family: .family, containerDefinitions: .containerDefinitions, networkMode: .networkMode, requiresCompatibilities: .requiresCompatibilities, cpu: .cpu, memory: .memory, executionRoleArn: .executionRoleArn, taskRoleArn: .taskRoleArn}')

# Register new task definition
NEW_REVISION_ARN=$(aws ecs register-task-definition \
    --cli-input-json "$NEW_TASK_DEF" \
    --region $REGION \
    | jq -r '.taskDefinition.taskDefinitionArn')

echo "New task definition registered: $NEW_REVISION_ARN"

# Update ECS service to use new revision
aws ecs update-service \
    --cluster $CLUSTER_NAME \
    --service $SERVICE_NAME \
    --task-definition $NEW_REVISION_ARN \
    --force-new-deployment \
    --region $REGION

echo "Deployment triggered successfully!"