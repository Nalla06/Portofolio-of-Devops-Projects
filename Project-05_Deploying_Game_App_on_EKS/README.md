# Project-06: 2048 Game App Deployment on AWS EKS

This project demonstrates how to deploy the 2048 Game App in a highly scalable environment using Amazon Elastic Kubernetes Service (EKS). The app can be deployed manually or automatically, based on our preference.

![EKS](https://imgur.com/oADneqS.png)

# Overview

This repository demonstrates two different approaches to deploying the 2048 Game App on AWS using Elastic Kubernetes Service (EKS):

## Type 1 (Manual Deployment):

 This approach involves manually creating a Dockerfile, Kubernetes Deployment, and Service to run the game app on EKS.

## Type 2 (Automated Deployment with Terraform): 

This approach uses Terraform to automate the entire process of creating the infrastructure, including the VPC, subnets, EKS cluster, and deploying the app on EKS.

Additionally, I have included images that represent the output at various stages of the deployment process for better visualization.


## Components

## Type 1: Manual Deployment

1. Dockerfile: The Dockerfile for building the application image.

2. Kubernetes Deployment: Defines the Kubernetes Deployment for running the Dockerized app in a pod.

3. Kubernetes Service: Creates a Kubernetes Service of type LoadBalancer to expose the app to the internet.

## Manual Steps:
1. Build the Docker image using the docker build command.
2.  Push the image to a Docker registry.
3.  Deploy the application and expose it using Kubernetes manifests (deployment.yaml and service.yaml).

This approach allows you to understand the process behind the deployment without automation tools.

## Type 2: Automated Deployment with Terraform

1. VPC Setup: Automates the creation of a VPC with CIDR block 192.168.0.0/16, along with public and private subnets.

2. EKS Cluster Setup: Creates an EKS Cluster and an EKS Node Group to host the application.

3. IAM Roles: Automatically configures the necessary IAM roles for both the EKS cluster and worker nodes.

4. Kubernetes Deployment: Automates the deployment of the 2048 Game App on the EKS cluster using Terraform.

5. Kubernetes Service: Exposes the app using a LoadBalancer service created automatically by Terraform.

This method automates the setup of all necessary AWS resources, making it easier to manage and scale the infrastructure.