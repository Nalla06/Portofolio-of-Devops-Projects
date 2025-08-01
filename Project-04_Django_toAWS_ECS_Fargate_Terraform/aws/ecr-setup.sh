#/bin/bash
# Set variables
AWS_REGION="us-east-1"
AWS_ACCOUNT_ID="631172387421"
ECR_REPO_NAME="hello-world-django-app"

# Authenticate Docker to ECR
aws ecr get-login-password --region $AWS_REGION | docker login --username AWS --password-stdin $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com

# Create ECR Repository
aws ecr create-repository --repository-name $ECR_REPO_NAME

# Tag and Push Image
docker tag hello-world-django-app:version-1 $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:version-1
docker push $AWS_ACCOUNT_ID.dkr.ecr.$AWS_REGION.amazonaws.com/$ECR_REPO_NAME:version-1