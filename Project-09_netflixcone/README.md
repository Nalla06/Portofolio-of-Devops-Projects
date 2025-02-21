# Netflix Clone DevOps Infrastructure

This project contains the complete infrastructure as code (IaC) setup for deploying a Netflix clone application using a modern DevOps pipeline. The infrastructure includes Terraform for provisioning AWS resources, Ansible for configuration management, Jenkins for CI/CD pipelines, Docker for containerization, and Kubernetes for orchestration.

![devsecops](https://imgur.com/vORuBnK.png)

## Architecture Overview

The infrastructure is designed with the following components:
- Jenkins server for CI/CD pipeline execution
- Kubernetes cluster (master and agent) for application deployment
- Prometheus and Grafana server for monitoring
- Integration with Trivy for security scanning and SonarQube for code quality

## Project-structure:

```plaintext
Netflix-Clone-Project/
│
├── terraform/
│   ├── main.tf                     # Main Terraform file for provisioning EC2 instances
│   ├── security.tf                 # Variables for EC2 instances, VPC, etc.
│
├── ansible/
│   ├── playbooks/
│   │   ├── jenkins_setup.yml       # Playbook to configure Jenkins master & agent
│   │   ├── docker_setup.yml        # Playbook to configure Docker on EC2 instances
│   │   ├── kubernetes_setup.yml    # Playbook to set up Kubernetes on EC2 instances
│   │   ├── prometheus_setup.yml    # Playbook to install Prometheus
│   │   ├── grafana_setup.yml       # Playbook to install Grafana
│   │   ├── sonarqube_setup.yml     # Playbook to install SonarQube
│   │   ├── trivy_setup.yml         # Playbook to install Trivy for vulnerability scanning
│   │   └── integrate_playbooks.yml # Playbook to integrate all setups
│   ├── inventory/                  # Hosts file for Ansible inventory
│   └── ansible.cfg                 # Ansible configuration file
│
├── jenkins/
│   ├── Jenkinsfile                 # Jenkins pipeline script defining the stages
│   ├── dockerfile                  # Dockerfile to build the Netflix clone image
│   ├── jenkins_config.yml          # Jenkins configuration file for plugins
│   └── credentials.yml             # Credentials for GitHub, SonarQube, Artifactory
│
├── kubernetes/
│   ├── kubernetes_config.yaml      # Kubernetes deployment configuration for Netflix Clone
│   ├── docker-compose.yml          # (If needed) for local testing of the Docker container
│   └── aws-cli-config.sh           # AWS CLI config for Jenkins Slave to connect with AWS
│
├── monitoring/
│   ├── prometheus/
│   │   ├── prometheus-config.yaml  # Prometheus configuration file
│   │   └── prometheus-deployment.yaml  # Prometheus Kubernetes deployment
│   ├── grafana/
│   │   ├── grafana-config.yaml     # Grafana configuration file
│   │   └── grafana-deployment.yaml  # Grafana Kubernetes deployment
│   └── helm-charts/                # Helm charts for deploying Prometheus & Grafana
│
└── README.md                       # Project overview and setup instructions

## Setup Instructions

### 1. Provision Infrastructure with Terraform

The Terraform configuration includes:
- `main.tf`: Defines EC2 instances for Jenkins, Kubernetes (master and agent), and Prometheus/Grafana
- `security.tf`: Configures security groups and networking rules

```bash
# Initialize Terraform
terraform init

# Validate the configuration
terraform validate

# Apply the configuration to provision the infrastructure
terraform apply
```

### 2. Configuration Management with Ansible

After provisioning the infrastructure, Ansible playbooks are used to configure the servers:

```bash
# Run the master playbook that orchestrates all other playbooks
ansible-playbook master_playbook.yml
```

The master playbook integrates the following individual playbooks:

1. `jenkins_install.yml`: Installs Jenkins server
2. `docker_install.yml`: Installs Docker on all required servers
3. `kubernetes_install.yml`: Sets up Kubernetes master and agent nodes
4. `jenkins_plugins.yml`: Installs Jenkins plugins:
   - Email notification plugin
   - Grafana integration plugin
   - Prometheus plugin
   - Trivy scanner plugin
   - SonarQube plugin
5. `prometheus_grafana_setup.yml`: Configures the Prometheus and Grafana server

### 3. Jenkins Pipeline Configuration

The CI/CD pipeline for the Netflix clone is defined in `Jenkinsfile` with the following stages:

1. **Checkout**: Retrieves source code from repository
2. **Build**: Compiles and packages the application
3. **Unit Tests**: Runs unit tests
4. **Code Quality Analysis**: Integrates with SonarQube for code quality checks
5. **Security Scan**: Uses Trivy to scan Docker image for vulnerabilities
6. **Build Docker Image**: Creates Docker image using the Dockerfile
7. **Push to Registry**: Pushes the Docker image to container registry
8. **Deploy to Kubernetes**: Deploys the application to Kubernetes cluster
9. **Monitor Deployment**: Sets up monitoring with Prometheus and visualizations in Grafana

### 4. Docker Configuration

The `Dockerfile` is configured to build the Netflix clone application with all dependencies.

```dockerfile
# Example Dockerfile snippet (actual implementation will vary based on tech stack)
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

### 5. Kubernetes Deployment

Kubernetes manifest files are provided for deploying the application:
- `deployment.yaml`: Defines the deployment configuration
- `service.yaml`: Sets up the service for external access
- `ingress.yaml`: Configures routing rules

## Monitoring Setup

The Prometheus and Grafana setup provides:
- Real-time monitoring of application performance
- Custom dashboards for visualizing metrics
- Alerts for critical issues
- Performance tracking over time

## Security Features

- Infrastructure security with AWS security groups
- Container vulnerability scanning with Trivy
- Code quality checks with SonarQube
- Secure Docker image building practices
- Kubernetes RBAC for access control

## Maintenance Procedures

### Updating the Infrastructure

```bash
# Pull the latest changes
git pull

# Update Terraform resources if needed
terraform apply

# Run Ansible playbooks to ensure configurations are up to date
ansible-playbook master_playbook.yml
```

### Pipeline Modifications

To modify the CI/CD pipeline, update the `Jenkinsfile` with new stages or configurations.

## Troubleshooting

Common issues and their solutions:
- Jenkins plugin conflicts: Clear workspace and rebuild
- Kubernetes deployment failures: Check logs with `kubectl logs`
- Terraform state issues: Ensure state file is properly maintained