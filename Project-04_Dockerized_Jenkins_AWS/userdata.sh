#!/bin/bash
# Update and install basic tools
sudo dnf update -y
sudo dnf install -y java-17-openjdk
sudo dnf install -y git
sudo dnf install -y maven
sudo dnf install -y docker
sudo dnf install -y wget
sudo dnf install -y nano
sudo dnf install -y vim

# Start and enable Docker service
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

# Install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo dnf clean all
sudo dnf repolist
sudo dnf install -y jenkins
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Set Environment Variables
echo "export JAVA_HOME=/usr/lib/jvm/java-17-openjdk" | sudo tee -a /etc/profile
echo "export MAVEN_HOME=/usr/share/maven" | sudo tee -a /etc/profile
echo "export PATH=$PATH:/usr/share/maven/bin:/usr/lib/jvm/java-17-openjdk/bin" | sudo tee -a /etc/profile
source /etc/profile

# Wait for Jenkins to start
sleep 30

# Install Jenkins Plugins using CLI
echo "Installing Jenkins Plugins..."
sudo dnf install -y jq
JENKINS_CLI_JAR="/var/lib/jenkins/jenkins-cli.jar"
JENKINS_URL="http://localhost:8080"
JENKINS_ADMIN_PASS=$(sudo cat /var/lib/jenkins/secrets/initialAdminPassword)

sudo wget "${JENKINS_URL}/jnlpJars/jenkins-cli.jar" -O $JENKINS_CLI_JAR
PLUGINS="git github maven-plugin docker-plugin pipeline-utility-steps publish-over-ssh"

for plugin in $PLUGINS; do
  java -jar $JENKINS_CLI_JAR -s $JENKINS_URL -auth admin:$JENKINS_ADMIN_PASS install-plugin $plugin
done

# Restart Jenkins to apply plugins
java -jar $JENKINS_CLI_JAR -s $JENKINS_URL -auth admin:$JENKINS_ADMIN_PASS safe-restart

# Add Jenkins user to Docker group
sudo usermod -aG docker jenkins
sudo systemctl restart docker

# Docker Login Setup (Optional: Replace with actual DockerHub credentials)
DOCKER_USER="nalla06"
DOCKER_PASS="kondapalli"
echo $DOCKER_PASS | docker login -u $DOCKER_USER --password-stdin

# Final Message
echo "Jenkins setup complete. Access it at http://$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4):8080"
