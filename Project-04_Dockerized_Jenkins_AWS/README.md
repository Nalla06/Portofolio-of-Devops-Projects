# Java Web App Deployment on Docker Using Jenkins and AWS

![AWS](https://imgur.com/Hk28ffE.png)

**In this project, we are going to deploy a Java Web app on a Docker Container built on an EC2 Instance through the use of Jenkins.**

/Java-Webapp-Deployment/
├── hello-world-app/   # Source code of your Java web app
├── Dockerfile         # Dockerfile for containerizing the app
├── Jenkinsfile        # Jenkins pipeline script
├── terraform/         # Directory containing all Terraform configuration files
│   ├── main.tf        # Main Terraform configuration
│   └── userdata.sh    # Script for provisioning EC2 instances
├── README.md          # Documentation for your project

#### Agenda

The project aims to automate the deployment of a Java web application as a Docker container on an EC2 instance using Jenkins. Below are the key steps achieved in this project:

1. Setup Jenkins
Provisioned an EC2 instance for Jenkins using Terraform. The instance is configured with:

Jenkins pre-installed and pre-configured with necessary plugins.
Basic security and access controls for Jenkins.

2. Setup & Configure Maven and Git
Installed Maven and Git for managing project dependencies and version control. Both tools were configured automatically via userdata.sh.

3. Integrate GitHub and Maven with Jenkins
Configured Jenkins to:

. Clone the GitHub repository containing the Java web app source code.
. Use Maven to build the application and manage dependencies.

4. Setup Docker Host
. Installed and configured Docker on the EC2 instance as part of the provisioning process. . The setup allows Docker to host and manage containers for the application.

5. Integrate Docker with Jenkins
Enabled Jenkins to:
. Build Docker images for the application.
. Push the images to Docker Hub using authentication credentials.

6. Automate the Build and Deploy Process Using Jenkins
Automated the entire pipeline through a Jenkinsfile. The pipeline performs the following:

. Pulls the latest code from GitHub.
. Builds the application using Maven.
. Creates a Docker image for the application.
. Pushes the Docker image to Docker Hub.
. Deploys the Docker container on the same EC2 instance.
7. Test the Deployment
Once the Docker container is running, the application can be tested via the exposed URL. Since a Tomcat Docker image is used, the application runs on port 8080 (default for Tomcat).

### Prerequisites

* AWS Account
* Git/ Github Account with the Source Code
* A local machine with CLI Access
* Familiarity with Docker and Git

## Step 1: Setup Jenkins Server on AWS EC2 Instance

* Setup a Linux EC2 Instance
* Install Java
* Install Jenkins
* Start Jenkins
* Access Web UI on port 8080

docker pull tomcat:latest
docker images
docker run -d --name tomcat-container -p 8085:8085 tomcat:latest


_*Log in to the Amazon management console, open EC2 Dashboard, click on the Launch Instance drop-down list, and click on Launch Instance as shown below:*_

![AWS Screenshot](https://github.com/Nalla06/Portofolio-of-Devops-Implementations/blob/main/Project-05_Dockerized_Jenkins_AWS/Screenshot%202024-12-11%20151216.png)
