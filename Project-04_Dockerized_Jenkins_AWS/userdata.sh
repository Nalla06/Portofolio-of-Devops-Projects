#!/bin/bash

# Update the system
sudo yum update -y

# Install Java (required for Jenkins)
sudo yum install -y java-11-openjdk

# Install Docker
sudo yum install -y docker
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Install Jenkins repository and key
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key

# Install Jenkins
sudo yum install -y jenkins
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Allow Jenkins to use Docker
sudo usermod -aG docker jenkins
sudo systemctl restart jenkins

# Output Jenkins initial admin password to a file
sudo cat /var/lib/jenkins/secrets/initialAdminPassword > /home/ec2-user/jenkins_password.txt
sudo chmod 600 /home/ec2-user/jenkins_password.txt
sudo chmod 600 /home/ec2-user/jenkins_password.txt

# Print completion message
echo "Setup Complete. Jenkins admin password saved to /home/ec2-user/jenkins_password.txt"