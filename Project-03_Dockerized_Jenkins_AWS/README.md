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

![AWS](https://imgur.com/a/ZxSC4ZK.png)

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


### New Read me 

To automate the process you're describing, you need to ensure the following key tasks are automated and can be achieved through Jenkins and Docker integration. Let's break it down step-by-step:

1. Set up Jenkins on your first EC2 instance:
You mentioned that you already have Jenkins installed, so we can move forward with configuring the necessary Jenkins plugins.
2. Install Required Jenkins Plugins:
You'll need a few essential plugins to accomplish the automation:

Docker Pipeline Plugin: This plugin allows Jenkins to build Docker images and run containers as part of your pipeline.
Pipeline Plugin: This plugin is necessary for creating Jenkins pipelines, which will define your automated steps for building, testing, and deploying.
Publish Over SSH Plugin: This will be used to push your artifacts to the Tomcat server (the second EC2 instance).
Deploy to container Plugin (Optional but useful for deploying directly to Tomcat from Jenkins).
Amazon EC2 Plugin (If you want Jenkins to create EC2 instances dynamically to run the builds or deploy).
Git Plugin: For source code management if your project is stored in a Git repository.
Maven Plugin (if you're building your web app with Maven).
To install these plugins:

Go to Manage Jenkins > Manage Plugins > Available tab.
Search and install the above plugins (you might need to restart Jenkins after installing).
3. Dockerization of the Web App:
You’ll need to have a Dockerfile in your repository for Jenkins to build the Docker image. Your Dockerfile should contain the necessary instructions to set up your web app.

Example Dockerfile:

Dockerfile
Copy
Edit
FROM tomcat:9-jdk11
COPY ./webapp.war /usr/local/tomcat/webapps/
EXPOSE 8080
CMD ["catalina.sh", "run"]
4. Create Jenkins Pipeline:
You need to create a pipeline script to automate the steps like:

Pull the latest code.
Build the Docker image.
Test the application.
Build and deploy the WAR file (artifact).
Push artifacts to the Tomcat server on another EC2 instance.
Here’s an example of a Jenkins Pipeline Script (Declarative Pipeline):

groovy
Copy
Edit
pipeline {
    agent any
    
    environment {
        // Add your SSH credentials and Tomcat details here
        TOMCAT_SERVER = "ec2-user@<TOMCAT_EC2_PUBLIC_IP>"
        TOMCAT_PATH = "/path/to/tomcat/webapps/"
    }

    stages {
        stage('Clone Repository') {
            steps {
                git 'https://your-repository-url.git'
            }
        }
        
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("my-webapp-image", ".")
                }
            }
        }
        
        stage('Run Docker Container') {
            steps {
                script {
                    docker.image("my-webapp-image").run("-p 8080:8080")
                }
            }
        }

        stage('Build Artifact') {
            steps {
                // If you need to build your WAR file or other artifacts
                sh 'mvn clean install'
            }
        }

        stage('Deploy to Tomcat') {
            steps {
                script {
                    // Use SSH Plugin to deploy to the remote Tomcat server
                    sh "scp target/my-webapp.war ${TOMCAT_SERVER}:${TOMCAT_PATH}"
                }
            }
        }
    }

    post {
        always {
            cleanWs()
        }
    }
}
5. Configuring the Second EC2 Instance (Tomcat Server):
Make sure Tomcat is running on your second EC2 instance.
Ensure the EC2 instance is accessible by the Jenkins server (configure security groups and SSH access).
Set up the SSH key or password-based authentication on the Jenkins server to connect to the Tomcat EC2 instance.
6. Transfer Artifacts to Tomcat Server:
You can automate artifact transfer in two ways:

Option 1: Using the Publish Over SSH Plugin:

Go to Manage Jenkins > Configure System > Publish over SSH.
Set up the server details with SSH credentials.
In your Jenkins Pipeline, you can use the scp command (as shown in the pipeline script above) to copy the artifact (.war file) to the Tomcat server's webapps directory.
Option 2: Using SCP Command in Pipeline (as shown in the pipeline script above).

7. Automating the Deployment:
Once the artifacts (WAR file) are transferred to the webapps/ directory of Tomcat, Tomcat will automatically deploy the web app when the new WAR is placed. If you want to make it a more explicit process, you can restart Tomcat in the pipeline as well:

groovy
Copy
Edit
sh "ssh ${TOMCAT_SERVER} 'sudo systemctl restart tomcat'"
8. Test the Setup:
Make sure Jenkins is able to build the Docker image, deploy the artifact to Tomcat, and the app is accessible via the Tomcat server on EC2.
Summary:
Install necessary Jenkins plugins for Docker, SSH, and artifact management.
Create a pipeline that automates the entire flow (build, test, deploy).
Configure Jenkins to interact with EC2 instances using SSH.
Push artifacts to the Tomcat server on the second EC2 instance.
Ensure automatic deployment in Tomcat when new artifacts are uploaded.
With this setup, Jenkins will automate the process of building, testing, and deploying your web application in Docker, with the final artifacts stored and deployed in the Tomcat server on another EC2 instance.

