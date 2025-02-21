# Project-10 Super Mario Game Deployment on AWS EKS


![supermario](https://imgur.com/rC4Qe8g.png)


# Super Mario Game Deployment on AWS EKS

## Project Overview

This project demonstrates the deployment of a Super Mario game application on AWS Elastic Kubernetes Service (EKS). The deployment process leverages various AWS services including ECR (Elastic Container Registry) and GitHub Actions for CI/CD.

## Table of Contents

- [Overview](#project-overview)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Setting Up the Environment](#setting-up-the-environment)
- [Building and Pushing Docker Image](#building-and-pushing-docker-image)
- [Deploying to EKS](#deploying-to-eks)
- [Cleaning Up](#cleaning-up)
- [GitHub Actions Workflow](#github-actions-workflow)
- [Contributing](#contributing)
- [License](#license)

## Prerequisites

Before you begin, ensure you have the following:

- An AWS Account
- AWS CLI installed and configured
- Docker installed
- kubectl installed
- Terraform installed
- Node.js installed
- A GitHub account with access to the repository

## Project Structure

```plaintext
Project-10_Supermario_game_deployment_AWS_EKS
├── README.md
├── docker
│   ├── Dockerfile
    ├── package.json
├── images
├── index.js
├── k8s
│   ├── k8s-deployment.yml
├── terraform-files
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   ├── ...
```

### Dockerfile

```Dockerfile name=docker/Dockerfile
# Use an official Node.js runtime as a parent image
FROM node:14

# Set the working directory
WORKDIR /usr/src/app

# Copy package.json
COPY package.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Expose the port your app runs on
EXPOSE 8080

# Define the command to run your app
CMD ["node", "app.js"]
```

### Kubernetes Deployment File

```yaml name=k8s/k8s-deployment.yml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: supermario-game
spec:
  replicas: 2
  selector:
    matchLabels:
      app: supermario-game
  template:
    metadata:
      labels:
        app: supermario-game
    spec:
      containers:
      - name: supermario-game
        image: 123456789012.dkr.ecr.us-east-1.amazonaws.com/supermario-game:latest
        ports:
        - containerPort: 8080
---
apiVersion: v1
kind: Service
metadata:
  name: supermario-service
spec:
  type: LoadBalancer
  ports:
  - port: 80
    targetPort: 8080
  selector:
    app: supermario-game
```

## Setting Up the Environment

1. **Clone the Repository:**

   ```sh
   git clone https://github.com/yourusername/Project-10_Supermario_game_deployment_AWS_EKS.git
   cd Project-10_Supermario_game_deployment_AWS_EKS
   ```

2. **Install AWS CLI:**

   Follow the instructions [here](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) to install AWS CLI.

3. **Configure AWS CLI:**

   ```sh
   aws configure
   ```

4. **Install Docker:**

   Follow the instructions [here](https://docs.docker.com/get-docker/) to install Docker.

5. **Install kubectl:**

   Follow the instructions [here](https://kubernetes.io/docs/tasks/tools/install-kubectl/) to install kubectl.

6. **Install Terraform:**

   Follow the instructions [here](https://learn.hashicorp.com/tutorials/terraform/install-cli) to install Terraform.

## Building and Pushing Docker Image

1. **Build the Docker Image:**

   ```sh
   docker build -t supermario-game:latest -f docker/Dockerfile .
   ```

2. **Tag the Docker Image:**

   ```sh
   docker tag supermario-game:latest 123456789012.dkr.ecr.us-east-1.amazonaws.com/supermario-game:latest
   ```

3. **Push the Docker Image to ECR:**

   ```sh
   aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin 123456789012.dkr.ecr.us-east-1.amazonaws.com
   docker push 123456789012.dkr.ecr.us-east-1.amazonaws.com/supermario-game:latest
   ```

## Deploying to EKS

1. **Initialize Terraform:**

   ```sh
   cd terraform-files
   terraform init
   ```

2. **Apply Terraform Configuration:**

   ```sh
   terraform apply -auto-approve
   ```

3. **Update kubeconfig:**

   ```sh
   aws eks update-kubeconfig --name super-mario-eks
   ```

4. **Deploy to Kubernetes:**

   ```sh
   kubectl apply -f k8s/k8s-deployment.yml
   ```

## Cleaning Up

To clean up the resources created by Terraform:

```sh
cd terraform-files
terraform destroy -auto-approve
```

## GitHub Actions Workflow

The GitHub Actions workflow automates the build, test, and deployment process. Below is the workflow file:

```yaml name=.github/workflows/deploy_super_mario_game_to_eks.yml
name: Deploy Super Mario Game to EKS

on:
  push:
    branches:
      - main
  workflow_dispatch:
    inputs:
      confirm_destroy:
        description: "Type 'yes' to confirm Terraform destroy"
        required: true

jobs:
  deploy:
    runs-on: self-hosted

    env:
      AWS_REGION: us-east-1
      ECR_REPOSITORY: supermario-game
      ECR_URI: 123456789012.dkr.ecr.us-east-1.amazonaws.com/supermario-game
      CLUSTER_NAME: super-mario-eks
      TERRAFORM_DIR: /home/nalla/Portofolio-of-Devops-Projects/Project-10_Supermario_game_deployment_AWS_EKS/terraform-files

    steps:
      - name: Set up environment variables
        run: |
          echo "Setting up environment variables..."
          export PATH=$HOME/aws-cli/v2/2.24.7/dist:$PATH
          echo "PATH is now: $PATH"

      - name: Check current AWS CLI installation
        run: |
          echo "Checking current AWS CLI installation..."
          if command -v aws &> /dev/null; then
            echo "AWS CLI is installed at: $(which aws)"
            echo "AWS CLI version: $(aws --version)"
          else
            echo "AWS CLI not found."
          fi

      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: ${{ env.AWS_REGION }}

      - name: Install Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '14'

      - name: Set up Terraform
        uses: hashicorp/setup-terraform@v1
        with:
          terraform_version: "1.0.0"

      - name: Verify Terraform directory
        run: |
          echo "Checking Terraform directory..."
          if [ ! -d "${{ env.TERRAFORM_DIR }}" ]; then
            echo "Error: Terraform directory not found at ${{ env.TERRAFORM_DIR }}"
            exit 1
          fi
          echo "Found Terraform directory. Contents:"
          ls -la ${{ env.TERRAFORM_DIR }}

      - name: Initialize Terraform
        run: |
          cd ${{ env.TERRAFORM_DIR }}
          echo "Initializing Terraform in $(pwd)"
          terraform init

      - name: Destroy Terraform resources if requested
        if: ${{ github.event.inputs.confirm_destroy == 'yes' }}
        run: |
          cd ${{ env.TERRAFORM_DIR }}
          echo "Starting Terraform destroy..."
          terraform destroy -auto-approve

      - name: Apply Terraform if not destroying
        if: ${{ github.event.inputs.confirm_destroy != 'yes' }}
        run: |
          cd ${{ env.TERRAFORM_DIR }}
          echo "Starting Terraform apply..."
          terraform apply -auto-approve
          echo "Waiting for infrastructure to be ready..."
          sleep 30

      - name: Configure ECR and build/push image
        if: ${{ github.event.inputs.confirm_destroy != 'yes' }}
        run: |
          export PATH=$HOME/aws-cli/v2/2.24.7/dist:$PATH
          DOCKER_DIR=/home/nalla/Portofolio-of-Devops-Projects/Project-10_Supermario_game_deployment_AWS_EKS/docker
          
          echo "Setting up ECR repository..."
          if ! aws ecr describe-repositories --repository-names ${{ env.ECR_REPOSITORY }} >/dev/null 2>&1; then
            echo "Creating ECR repository..."
            aws ecr create-repository --repository-name ${{ env.ECR_REPOSITORY }}
          else
            echo "ECR repository already exists."
          fi
          
          echo "Logging into ECR repository: ${{ env.ECR_URI }}"
          aws ecr get-login-password --region ${{ env.AWS_REGION }} | docker login --username AWS --password-stdin ${{ env.ECR_URI }}
          
          if [ ! -d "$DOCKER_DIR" ]; then
            echo "Error: Docker directory not found at $DOCKER_DIR"
            exit 1
          fi
          
          echo "Building Docker image..."
          docker build -t ${{ env.ECR_REPOSITORY }}:latest -f $DOCKER_DIR/Dockerfile .
          docker tag ${{ env.ECR_REPOSITORY }}:latest ${{ env.ECR_URI }}:latest
          
          echo "Pushing image to ECR..."
          docker push ${{ env.ECR_URI }}:latest

      - name: Configure kubectl
        if: ${{ github.event.inputs.confirm_destroy != 'yes' }}
        uses: azure/setup-kubectl@v3

      - name: Deploy to Kubernetes
        if: ${{ github.event.inputs.confirm_destroy != 'yes' }}
        run: |
          export PATH=$HOME/aws-cli/v2/2.24.7/dist:$PATH
          K8S_DIR=/home/nalla/Portofolio-of-Devops-Projects/Project-10_Supermario_game_deployment_AWS_EKS/k8s
          
          echo "Configuring kubectl..."
          aws eks update-kubeconfig --name ${{ env.CLUSTER_NAME }}
          
          if [ ! -d "$K8S_DIR" ]; then
            echo "Error: k8s directory not found at $K8S_DIR"
            exit 1
          fi
          
          cd $K8S_DIR
          echo "Applying Kubernetes configurations..."
          kubectl apply -f k8s-deployment.yml
          
          echo "Updating deployment with new image..."
          kubectl set image deployment/supermario-game supermario-game=${{ env.ECR_URI }}:latest
          
          echo "Waiting for deployment to complete..."
          kubectl rollout status deployment/supermario-game --timeout=180s
          
          echo "Getting service URL..."
          HOSTNAME=$(kubectl get svc supermario-service -o jsonpath="{.status.loadBalancer.ingress[0].hostname}")
          echo "Service is available at: $HOSTNAME"
```

