# Deploy Django Application on AWS using ECS and ECR

![AWS](https://imgur.com/wLMcRHS.jpg)

This project demonstrates how to deploy a Django-based application onto AWS using ECS (Elastic Container Service) and ECR (Elastic Container Registry). The process includes creating a Docker image of the application, pushing it to ECR, and deploying the application on ECS. The application is then tested using Django’s built-in web server.


## Prerequisite

* Django
* Background on Docker
* AWS Account
* Python
 -->


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


Here is a complete Terraform configuration for automating the deployment of a Django application using AWS ECS and ECR.

### Terraform Configuration for Deploying Django Application on AWS
This setup includes the following resources:

1. ECR for storing the Docker image.
2. ECS Cluster to manage the Docker containers.
3. ECS Task Definition for container orchestration.
4. ECS Service to manage the application scaling and deployment.
5. Application Load Balancer (ALB) to route traffic to ECS tasks.
https://imgur.com/a/CHpcV02
## What are Dockers and Containers?

![Docker](https://imgur.com/raGErLx.png)

![AWS](https://imgur.com/a/ZxSC4ZK.png)

Project Workflow
1. Set Up a VPC:
    . Created a custom VPC with public and private subnets.
    . Attached an Internet Gateway and NAT Gateway for secure connectivity.
2. Build Security Groups:
    . Configured security groups for the ALB, ECS services, and ECR to control traffic access.
3. Create ECR Repository:
    . Used Terraform to create an ECR repository for storing the Docker image.
4. Build and Push Docker Image:
    . Wrote a shell script to build the Docker image for the Django app and push it to ECR.
5. Provision ECS Cluster and Services:
    . Created an ECS cluster and deployed the Django app as a task definition.
    . Configured the ECS service to run multiple tasks behind an ALB.
6. Configure Load Balancer:
    . Set up an Application Load Balancer to expose the Django app to the internet.
7. Deploy Application:
    . Verified the app was running by accessing the ALB's public DNS.


### Docker Workflow

**Docker is an open platform software. It is used for developing, shipping, and running applications. Docker virtualizes the operating system of the computer on which it is installed and running. It provides the ability to package and run an application in a loosely isolated environment called a container. A container is a runnable instance of a docker image. You can create, start, stop, move, or delete a container using the Docker API or CLI. You can connect a container to one or more networks, attach storage to it, or even create a new docker image based on its current state.**

## What is AWS Elastic Container Registry?

**Amazon Elastic Container Registry (Amazon ECR) is a managed container image registry service. Customers can use the familiar Docker CLI, or their preferred client, to push, pull, and manage images. Amazon ECR provides a secure, scalable, and reliable registry for your Docker images.**

### ECR Steps

Here comes the task in which we create the repository on AWS using ECR where our application docker image will reside. To begin with the creation of a repository on ECR we first search ECR on AWS console and follows the below steps.

1. **Create a Docker File** — Add the “Dockerfile” to the Django application. It contains the series of command which will be required for the creation of docker image.

2. **Build your Docker Image** — Use the below command to create the docker image name as “django-app:version:1”.

```
docker build -t hello-world-django-app:version-1 
```

3. Check whether the docker image is created or not using the below command.

```
docker images | grep hello-world-django-app 
```

4. **Create Repository on AWS ECR** — It's time to open the AWS console and search for ECR. Then, click on the Create Repository button.

**You will find two options for the visibility of your repository i.e, Private and Public. The Private repository access is managed by IAM and repository policy permissions. Once you click on create repository button then, you need to give the name of your repository. If you enabled the scan on push option then, it helps in identifying software vulnerabilities in your container images**

5. **Push the created docker image of the Django application on Step 2 to AWS ECR** —

a) Authenticate your Docker client to the Amazon ECR registry. Authentication tokens must be obtained for each registry used, and these tokens are valid for 12 hours. The easiest way of doing this is to get the AWS `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`. Then run the below command.

```
export AWS_ACCESS_KEY_ID=******
export AWS_SECRET_ACCESS_KEY=******
```

After exporting the `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`, login to the AWS account using the below command.

```
aws ecr get-login-password --region region | docker login --username AWS --password-stdin aws_account_id.dkr.ecr.region.amazonaws.com
```

b) Identify the image to push using the **docker images** command:

```
REPOSITORY                                                                TAG                     IMAGE ID          CREATED            SIZE
django-app version-1    480903dd8        2 days ago          549MB
```

c) Tag your image with the Amazon ECR registry, repository, and optional image tag name combination to use. The registry format is `aws_account_id.dkr.ecr.region.amazonaws.com`. The repository name should match the repository that you created for your image.

The following example tags an image with the ID `480903dd8` as `aws_account_id.dkr.ecr.region.amazonaws.com/hello-world-django-app`.

```
docker tag 480903dd8 aws_account_id.dkr.ecr.region.amazonaws.com/hello-world-django-app
```

d) Push the docker image using the **docker push** command:

```
docker push aws_account_id.dkr.ecr.region.amazonaws.com/hello-world-django-app
```

## What is AWS Elastic Container Service?

**Amazon Elastic Container Service (ECS) is a highly scalable, high-performance container management service that supports Docker containers and allows you to easily run applications on a managed cluster of Amazon EC2 instances. With Amazon ECS we can install, operate and scale our application with its own cluster management infrastructure. Using some simple API calls, we can launch and stop our Docker-enabled applications, query the logs of our cluster, and access many familiar features like security groups, Elastic Load Balancer, EBS volumes, and IAM roles. We can use Amazon ECS to schedule the placement of containers across our cluster based on our resource needs and availability requirements. We can also integrate our own scheduler or third-party schedulers to meet business or application-specific requirements.**

### ECS Steps

Now the time has come to launch our first EC2 instance using AWS ECS. To begin with, let’s first search ECS on AWS console and follows the below steps.

1. **Create Cluster** — The cluster creation console provides a simple way to create the resources and it lets you customize several common cluster configuration options. Don’t forget to select the region to use your cluster from the navigation pane.

2. **Launch EC2 instance** — In this step, we are doing the configuration of our cluster. Some of these configurations are Network configuration, CloudWatch Container Insights, and Auto-Scaling groups. This is the most crucial step while creating your cluster because some of the configurations after the creation of the cluster cannot be reverted.

3. **Create a Service that runs the task definition** — A service defines how to run your ECS service. Some of the important parameters that are specified in service definition are cluster, launch type, and task definition.

4. **Create a Task** — To run docker containers on AWS ECR we need to create the task definition first. We can configure multiple containers and data storage in a single task definition. While creating the task definition we specify which ECR to be used for which container and also the port mappings.

5. **Run instance by triggering the created task** — After doing all the above steps successfully, we are now at the stage of triggering our created task by entering into the cluster. After running our task we can check in the EC2 console whether our created instance is running or not.