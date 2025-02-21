# Super Mario Game Deployment on AWS EKS with GitHub Actions

This repository contains an automated CI/CD pipeline using GitHub Actions to deploy a Super Mario game on AWS EKS. The pipeline automates infrastructure provisioning, container building, and application deployment.

## Project Overview

This project implements a fully automated deployment pipeline for a Super Mario game clone on AWS EKS. Using GitHub Actions, the pipeline provisions infrastructure with Terraform, builds and pushes Docker images to ECR, and deploys the application to EKS.

## Architecture Components

- **GitHub Actions**: Automation pipeline orchestrator
- **Terraform**: Infrastructure as Code for AWS resources
- **AWS ECR**: Container registry for game images
- **AWS EKS**: Kubernetes service for container orchestration
- **Docker**: Containerization of the Super Mario game
- **Kubernetes**: Orchestration of game containers

## Workflow Architecture

```
GitHub Repository
       │
       ▼
GitHub Actions Workflow
       │
       ├─── Terraform Apply ──► AWS EKS Cluster Creation
       │                         + Supporting Infrastructure
       │
       ├─── Docker Build ────► Super Mario Game Container
       │
       ├─── ECR Push ───────► AWS ECR Repository
       │
       └─── K8s Apply ──────► Deployment to EKS Cluster
```

## Repository Structure

```
.
├── .github/
│   └── workflows/
│       └── deploy.yml    # GitHub Actions workflow definition
├── terraform/
│   ├── main.tf           # EKS cluster and ECR repository configuration
│   ├── security_group.tf # Terraform security
├── kubernetes/
│   ├── deployment.yaml   # Kubernetes deployment configuration
│   ├── service.yaml      # Kubernetes service configuration
│   └── ingress.yaml      # Kubernetes ingress configuration
├── docker/
│   ├── Dockerfile        # Container definition for Super Mario game
│   ├── package.json      # Key dependencies include
│   └── index.js          # sets up middleware, and establishes API routes
└── README.md             # This documentation
```

## Automated Deployment Process

The GitHub Actions workflow (`main.yml`) automates the entire deployment process:

1. **Infrastructure Provisioning**:
   - Initializes Terraform
   - Creates AWS EKS cluster
   - Sets up ECR repository
   - Configures networking and security

2. **Container Build and Push**:
   - Builds the Super Mario game container using the Dockerfile
   - Authenticates with AWS ECR
   - Tags and pushes the container image to ECR

3. **Application Deployment**:
   - Configures kubectl to connect to the EKS cluster
   - Applies Kubernetes manifests (deployment.yaml, service.yaml)
   - Sets up ingress rules for public access

## GitHub Actions Workflow

The main workflow is defined in `.github/workflows/main.yml`:

```yaml
name: Deploy Super Mario to EKS

on:
  push:
    branches: [ main ]
  workflow_dispatch:

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Checkout code
        uses: actions/checkout@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Setup Terraform
        uses: hashicorp/setup-terraform@v2

      - name: Terraform Init
        run: cd terraform && terraform init

      - name: Terraform Apply
        run: cd terraform && terraform apply -auto-approve

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      - name: Build and push Docker image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: supermario-repo
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG

      - name: Update kube config
        run: aws eks update-kubeconfig --name supermario-cluster --region us-east-1

      - name: Deploy to Kubernetes
        run: |
          sed -i "s|IMAGE_URL|${{ steps.login-ecr.outputs.registry }}/supermario-repo:${{ github.sha }}|g" kubernetes/deployment.yaml
          kubectl apply -f kubernetes/
```

## Terraform Configuration

The Terraform configuration provisions:
- VPC with public and private subnets
- EKS cluster with managed node groups
- ECR repository for container images
- IAM roles and policies for EKS service accounts

## Dockerfile

The Dockerfile packages the Super Mario game application:

```dockerfile
FROM node:16-alpine as build
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .
RUN npm run build

FROM nginx:alpine
COPY --from=build /app/build /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## Kubernetes Manifests

The Kubernetes manifests define:
- Deployment configuration with container specifications
- Service for internal networking
- Ingress for public access
- ConfigMaps for application configuration

## Setup Instructions

1. **Fork and Clone the Repository**:
   ```bash
   git clone https://github.com/yourusername/supermario-eks.git
   cd supermario-eks
   ```

2. **Configure GitHub Secrets**:
   - Navigate to your GitHub repository → Settings → Secrets
   - Add the following secrets:
     - `AWS_ACCESS_KEY_ID`
     - `AWS_SECRET_ACCESS_KEY`

3. **Trigger the Workflow**:
   - Push changes to the main branch, or
   - Manually trigger the workflow from the Actions tab

## Monitoring and Management

After deployment:
- Access the game via the Load Balancer URL (output from Terraform)
- Monitor the EKS cluster through AWS Console or kubectl
- View logs in CloudWatch
- Check deployment status with:
  ```bash
  kubectl get deployments
  kubectl get pods
  kubectl get services
  ```

## Troubleshooting

Common issues and solutions:

1. **GitHub Actions workflow failures**:
   - Check workflow logs in the GitHub Actions tab
   - Verify AWS credentials are correctly set as GitHub secrets

2. **Terraform errors**:
   - Ensure IAM permissions are sufficient
   - Check for syntax errors in Terraform files

3. **Container build failures**:
   - Review Dockerfile for errors
   - Check ECR repository permissions

4. **Kubernetes deployment issues**:
   - Verify EKS cluster is running
   - Check pod logs with `kubectl logs <pod-name>`
   - Ensure service account permissions are correct

## Cleanup

To remove all deployed resources:

```bash
# Run the cleanup workflow or execute:
kubectl delete -f kubernetes/
cd terraform && terraform destroy -auto-approve
```

## Security Considerations

- IAM roles use the principle of least privilege
- Network security groups restrict access to EKS cluster
- Secrets are managed through GitHub Secrets
- Container images are scanned for vulnerabilities