#!/bin/bash

# Set variables
AWS_REGION="us-east-1"
CLUSTER_NAME="django-ecs-cluster"
SERVICE_NAME="django-service"
TASK_DEFINITION="django-task"

# Register ECS Task Definition
aws ecs register-task-definition --cli-input-json file://aws/ecs-task-definition.json

# Create ECS Cluster
aws ecs create-cluster --cluster-name $CLUSTER_NAME

# Create ECS Service
aws ecs create-service \
  --cluster $CLUSTER_NAME \
  --service-name $SERVICE_NAME \
  --task-definition $TASK_DEFINITION \
  --desired-count 1 \
  --launch-type EC2