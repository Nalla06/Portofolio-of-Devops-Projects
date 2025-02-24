#!/bin/bash
# Update and install basic tools
sudo dnf update -y
sudo dnf install -y java-17-openjdk
sudo dnf install -y git
sudo dnf install -y docker
sudo dnf install -y wget
sudo dnf install -y nano
sudo dnf install -y vim

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Install Tomcat (Optional - if not already installed)
cd /opt
sudo wget https://downloads.apache.org/tomcat/tomcat-9/v9.0.46/bin/apache-tomcat-9.0.46.tar.gz
sudo tar -xzvf apache-tomcat-9.0.46.tar.gz
sudo mv apache-tomcat-9.0.46 tomcat

# Dockerize Tomcat and deploy the WAR file
# Pull the Tomcat image from Docker Hub (optional, if you're using Docker)
sudo docker pull tomcat:9-jdk11

# Create a directory for your app inside the container (if needed)
sudo mkdir -p /opt/tomcat/webapps

# Docker Run Command to Start Tomcat
# You can run this command with the WAR file once Jenkins deploys it
sudo docker run -d -p 8080:8080 --name tomcat-container -v /opt/tomcat/webapps:/usr/local/tomcat/webapps tomcat:9-jdk11
