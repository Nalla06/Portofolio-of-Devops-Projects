# Deploy Django Application on AWS using ECS and ECR

![AWS](https://imgur.com/wLMcRHS.jpg)

This project demonstrates how to deploy a Django-based application onto AWS using ECS (Elastic Container Service) and ECR (Elastic Container Registry). The process includes creating a Docker image of the application, pushing it to ECR, and deploying the application on ECS. The application is then tested using Django’s built-in web server.


## Prerequisite

* Django
* Background on Docker
* AWS Account
* Python
* Docker


## Django Web Framework

***Django is a high-level Python web framework that encourages rapid development and clean, pragmatic design. It is free and open-source, has a thriving and active community, great documentation, and many free and paid-for support options. It uses HTML/CSS/Javascript for the frontend and python for the backend.***

## Steps Followed

1. **Terraform Setup**: Initialize Terraform to manage AWS infrastructure as code. Use Terraform to provision VPC, ECS Cluster, ALB, RDS, IAM Roles, and ECR repository.
  
2. **ECR**: Create an ECR repository to store the Docker image of the Django app, build the image, and push it to ECR for deployment.

3. **ECS & Fargate**: Deploy the Django app on AWS Fargate using ECS, configured with the Docker image from ECR, ensuring scalability and serverless compute.

4. **RDS**: Set up AWS RDS for PostgreSQL to handle the database persistence, and configure the Django app to connect to RDS.

5. **Health Checks**: Implement health checks for the application using the ALB to monitor ECS task health.

6. **Custom Domain & SSL**: Configure Route 53 for domain registration, generate an SSL certificate with ACM, and secure the app with HTTPS.

7. **Nginx**: Use Nginx for serving static files and as a reverse proxy to the Django app for optimized performance.

8. **Static Files**: Manage static files efficiently using Nginx or an S3 bucket, ensuring better user experience and app performance.

9. **Allowed Hosts**: Update Django’s `ALLOWED_HOSTS` setting to secure the app from HTTP Host header attacks.

##  Project setup
![Docker](https://imgur.com/raGErLx.png)
# 1. **Create a Django Project**

# Create a new directory for the project:
$ mkdir django-ecs-terraform && cd django-ecs-terraform

# Inside the project folder, create the app directory and navigate to it:
$ mkdir app && cd app

# Set up a Python virtual environment:
$ python3.12 -m venv env
$ source env/bin/activate

# Install Django inside the virtual environment:
(env)$ pip install django==4.2.7

# Create a new Django project:
(env)$ django-admin startproject hello_django .

# Run migrations:
(env)$ python manage.py migrate

# Start the Django development server:
(env)$ python manage.py runserver

# Navigate to http://localhost:8000/ to view the Django welcome screen.

# When done, stop the server and deactivate the virtual environment:
(env)$ deactivate

# You can also remove the virtual environment if you want:
$ rm -rf env

# 2. Add a requirements.txt File
Create a `requirements.txt` file with the following content:

# Django==4.2.7
# gunicorn==21.2.0

# 3. **Create a Dockerfile**

# Dockerfile to containerize the Django app:

# Pull official base image
FROM python:3.10.0-slim

# Set the working directory in the container
WORKDIR /usr/src/app

# Set environment variables for Python
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install dependencies
RUN pip install --upgrade pip
COPY ./requirements.txt .
RUN pip install -r requirements.txt

# Create a user with UID 1000 and GID 1000
RUN groupadd -g 1000 appgroup && \
    useradd -r -u 1000 -g appgroup appuser

# Switch to this user
USER 1000:1000

# Copy project files into the container
COPY . .

# 4. **Configure Django Settings for Testing**

# Set `DEBUG = True` and `ALLOWED_HOSTS = ['*']` in the `settings.py` file.

# 5. **Build and Run Docker Container**

# Build the Docker image:
$ docker build -t django-ecs .

# Run the Docker container:
$ docker run \
    -p 8007:8000 \
    --name django-test \
    django-ecs \
    gunicorn hello_django.wsgi:application --bind 0.0.0.0:8000

# Now, your Django app should be available at http://localhost:8007/

![image alt](https://github.com/Nalla06/Portofolio-of-Devops-Projects/blob/8413f650b42eb64bd0d8341cc313ebd8ab412f64/Project-03_Django_AWS_ECS_ECR/Django_page.png)

## ECR Repo to push the images 

## Push the Docker Image to Amazon ECR
Create a New ECR Repository
Head to the ECR console and create a new repository named django-app. Make sure the tags are set to mutable. For more information, check out the Image Tag Mutability guide.

## Build and Tag the Docker Image
Now, navigate back to your terminal and rebuild the Docker image, making sure to tag it for your ECR repository. Replace <AWS_ACCOUNT_ID> with your actual AWS account ID:

$ docker build -t <AWS_ACCOUNT_ID>.dkr.ecr.us-west-1.amazonaws.com/django-app:latest .
We're using the us-west-1 region in this tutorial, but you can change the region if needed.

## Authenticate Docker with ECR

$ aws ecr get-login-password --region us-west-1 | docker login \
    --username AWS --password-stdin \
    <AWS_ACCOUNT_ID>.dkr.ecr.us-west-1.amazonaws.com
This command retrieves an authentication token and logs you into the ECR repository.

## Push the Docker Image
Finally, push the tagged image to your ECR repository:

$ docker push <AWS_ACCOUNT_ID>.dkr.ecr.us-west-1.amazonaws.com/django-app:latest

Here is a complete Terraform configuration for automating the deployment of a Django application using AWS ECS and ECR.

###  Next, we will configure the following AWS resources using Terraform:

1. VPC
  Create a Virtual Private Cloud (VPC) to host your resources.

2. Public and Private Subnets
  Define both public and private subnets to segregate your resources based on access levels.

3. Routing Tables
  Set up routing tables for directing traffic to appropriate destinations.

4. Internet Gateway
  Attach an Internet Gateway to the VPC to enable internet access for resources in the public subnet.

5. Security Groups
  Configure security groups for controlling access to instances within the VPC.

6. Load Balancers, Listeners, and Target Groups
  Set up an Application Load Balancer (ALB) with listeners and target groups to manage incoming traffic.

7. IAM Roles and Policies
  Create IAM roles and policies to grant permissions for ECS, ECR, and other AWS resources.

## ECS Resources
8. Task Definition (with multiple containers)
  Define ECS task definitions for multiple containers that will run within ECS tasks.

9. Cluster
  Create an ECS cluster to house your ECS services.

10. Service
  Create ECS services that define how tasks will be deployed and maintained.

11. Health Checks and Logs
  Configure health checks for the ECS tasks and set up logging to monitor the health of your resources.
## Monitoring and Logging
12. Logs
  Configure CloudWatch Logs to capture application and infrastructure logs for better observability.


![image alt](https://github.com/Nalla06/Portofolio-of-Devops-Projects/blob/ce4b4f1c701b22c8f75e3f06fc5cc988fca28e38/Project-03_Django_AWS_ECS_ECR/Page%20after%20dockefile%20build%20image%20.png)

