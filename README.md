# Portofolio-of-Devops-Implementations
This repository showcases various DevOps projects that demonstrate my skills in CI/CD, containerization, infrastructure automation, and cloud deployments. Each project includes practical examples of using tools like Jenkins, GitLab CI/CD, Docker, Kubernetes, Terraform, and AWS.

##  Project-01: Deploy Java Application on AWS 3-Tier Architecture

#### Summary:

This project focuses on deploying a Java-based application using an AWS 3-tier architecture model. It emphasizes scalability, high availability, and security by utilizing AWS services like EC2, RDS, VPC, Auto Scaling, and Load Balancers. The application is built using Maven, with artifact management handled via JFrog Artifactory and static code analysis integrated with SonarCloud.

![3-tier application](https://imgur.com/3XF0tlJ.png)

# Key Highlights:

1. Designed a custom VPC with private and public subnets.
2. Implemented a 3-tier model:
     . Frontend: Nginx with a public Network Load Balancer.
     . Backend: Tomcat servers with a private Load Balancer.
     . Database: RDS MySQL in a private subnet.
3. Automated deployment using Golden AMIs for Nginx, Tomcat, and Maven.
4. Integrated SonarCloud for code quality and JFrog Artifactory for artifact storage.
5. Set up CloudWatch monitoring for logs and alarms.

This project highlights end-to-end deployment using best practices in AWS infrastructure design and DevOps tools.

# Project-02: Linux Basics for Cloud & DevOps Engineers
Overview

![Linux](https://imgur.com/xedzuwy.png)

This assignment covers fundamental Linux skills required for DevOps engineers. It involves user and group management, file system operations, and AWS EC2 management.

## Tasks Overview

### User & Group Management:
- Create users and groups  
- Assign primary and secondary groups  
- Set file and directory permissions  

### File System Operations:
- Create, move, rename, and delete files & directories  
- Modify file contents using CLI and editors  

### AWS EBS Volume Management:
- Attach, format, mount, and verify EBS volume  
- Unmount and delete storage  

### Cleanup & Termination:
- Delete users, groups, and home directories  
- Detach and delete EBS volume  
- Terminate EC2 instance  


# Project-03 : Deploying Django App on AWS Fargate using Terraform
 
![AWS](https://imgur.com/wLMcRHS.jpg)

### **Project Overview: 

This project demonstrates how to deploy a scalable, production-ready Django application using AWS Fargate and Terraform. The application is containerized with Docker, provisioned on Amazon ECS using Fargate, and connected to a managed PostgreSQL database via AWS RDS. The solution is optimized for scalability, high availability, and security, ensuring the app can handle production traffic with ease.

**Key Features:**

- **Infrastructure as Code**: Provision all AWS resources, including VPC, ECS Cluster, RDS, and ECR, using Terraform.
- **Containerization**: Build and store the Django app Docker image in AWS ECR for deployment to ECS Fargate.
- **Database Persistence**: Use AWS RDS to provide managed PostgreSQL database persistence for the Django application.
- **Secure HTTPS Traffic**: Configure SSL with AWS ACM for a secure HTTPS connection.
- **Scalability**: Leverage ECS Fargate for serverless container orchestration, ensuring that the application scales seamlessly based on demand.
- **Efficient Static File Management**: Use Nginx to serve static files, optimizing performance and ensuring a smooth user experience.

# Project-04 :  Java Web App Deployment on Docker Using Jenkins and AWS

![AWS](https://imgur.com/Hk28ffE.png)

# Project Overview

This project demonstrates the deployment of a Java Web application on a Docker container hosted on an AWS EC2 instance using Jenkins as the CI/CD automation tool. By integrating Terraform for infrastructure provisioning and automation scripts for setup, this project achieves a seamless deployment process. The deployed application runs on a Tomcat Docker image, with the containerized app being managed via Jenkins pipelines.

## Automation Using Terraform
### How Terraform Was Used:
1. Provisioning Resources:

Terraform was used to provision the EC2 instance, security groups, and networking components.
   . Terraform configured the instance with a userdata.sh script, which handled:
   . Installing Jenkins, Docker, Git, Maven, and Java.
   . Installing required Jenkins plugins automatically.

2. User Data Configuration (userdata.sh):
  The userdata.sh script is a crucial part of the Terraform setup. It installs all dependencies, configures Jenkins with necessary plugins, and ensures Docker is ready to use. Here's what the script does:
   . Installs OpenJDK (Java).
   . Sets up Maven and Git.
   . Installs and configures Docker.
   . Installs Jenkins and required plugins.

3. Automated Deployment Pipeline: After the infrastructure setup, Jenkins was used to run a  pipeline that:

   . Clones the repository.
   . Builds the Java web app with Maven.
   . Creates a Docker image and pushes it to Docker Hub.
   . Deploys the app as a Docker container.



# Project-06 : 2048 Game App on EKS Deployment 

![EKS](https://imgur.com/oADneqS.png)

This project demonstrates the deployment of the 2048 Game App on Amazon EKS using two methods:

## Type 1: Manual Deployment

This method involves manually building and deploying the app using Docker to containerize the application, and Kubernetes for deployment and service management.

## Type 2: Automated Deployment with Terraform

In this method, Terraform is used to automate the entire deployment process, including the creation of VPC, EKS cluster, and the Kubernetes resources necessary for the game app.

# Project-07: Implementation of the Entire Advanced CI/CD Pipeline with Major DevOps Tools

![devops](https://imgur.com/WcCpKVU.png)

## Overview

This project sets up a Jenkins CI/CD pipeline on AWS using Terraform. It provisions a Virtual Private Cloud (VPC), subnets, security groups, and EC2 instances for Ansible, Jenkins Master, and Jenkins Agent.

## Steps Followed in the Implementation of the Entire CI/CD Pipeline:

The following tools and technologies have been integrated to automate a full CI/CD pipeline:

1. Infrastructure Provisioning: Terraform for VPC, EC2 instances, security groups.
2. Configuration Management: Ansible for Jenkins configuration and SSH key management.
3. CI/CD Pipeline: Jenkins with multibranch pipeline, GitHub webhook triggers.
4. Code Quality: SonarQube integration for static code analysis.
5. Artifact Management: JFrog Artifactory for storing Docker images and build artifacts.
6. Containerization: Docker for creating container images.
7. Container Orchestration: AWS EKS for Kubernetes container management.
8. Deployment: Deploy Docker images to EKS using Kubernetes resources.
9. Monitoring: Prometheus and Grafana for cluster monitoring.

# Project-09: Netflix Clone DevOps Infrastructure

This repository contains the complete infrastructure as code (IaC) setup for deploying a Netflix clone application using a modern DevOps pipeline. The infrastructure includes Terraform for provisioning AWS resources, Ansible for configuration management, Jenkins for CI/CD pipelines, Docker for containerization, and Kubernetes for orchestration.
![devsecops](https://imgur.com/vORuBnK.png)

## Overview

The infrastructure is designed with the following components:

1. Jenkins server for CI/CD pipeline execution
2. Kubernetes cluster (master and agent) for application deployment
3. Prometheus and Grafana server for monitoring
4. Integration with Trivy for security scanning and SonarQube for code quality

# Project-10 Super Mario Game Deployment on AWS EKS


![supermario](https://imgur.com/rC4Qe8g.png)


## **Overview**

This project automates the deployment of the Super Mario game on an AWS EKS cluster using **Terraform, Ansible, and Jenkins**. The workflow provisions an EC2 instance, sets up an EKS cluster, and deploys the containerized Super Mario game on Kubernetes.

## **Project Architecture**

1. **Terraform** provisions an AWS EC2 instance and an EKS cluster.
2. **Ansible** installs necessary tools (AWS CLI, Terraform, kubectl, Helm) on EC2.
3. **Terraform** creates EKS cluster and provisions worker nodes.
4. **Kubernetes** deploys the Super Mario game using a YAML configuration.
5. **Jenkins** automates the entire process.
