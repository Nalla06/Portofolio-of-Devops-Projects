# Portofolio-of-Devops-Implementations
This repository showcases various DevOps projects that demonstrate my skills in CI/CD, containerization, infrastructure automation, and cloud deployments. Each project includes practical examples of using tools like Jenkins, GitLab CI/CD, Docker, Kubernetes, Terraform, and AWS.

##  Project-01: Deploy Java Application on AWS 3-Tier Architecture
Summary:
This project focuses on deploying a Java-based application using an AWS 3-tier architecture model. It emphasizes scalability, high availability, and security by utilizing AWS services like EC2, RDS, VPC, Auto Scaling, and Load Balancers. The application is built using Maven, with artifact management handled via JFrog Artifactory and static code analysis integrated with SonarCloud.

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

## Project-06 : 2048 Game App on EKS Deployment 

This project demonstrates the deployment of the 2048 Game App on Amazon EKS using two methods:

## Type 1: Manual Deployment

This method involves manually building and deploying the app using Docker to containerize the application, and Kubernetes for deployment and service management.

## Type 2: Automated Deployment with Terraform

In this method, Terraform is used to automate the entire deployment process, including the creation of VPC, EKS cluster, and the Kubernetes resources necessary for the game app.