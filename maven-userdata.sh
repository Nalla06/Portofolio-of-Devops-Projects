#!/bin/bash
# Update package manager
sudo yum update -y

# Install Git
sudo yum install -y git

# Install JDK 11
sudo yum install java-17 -y
# Download Apache Maven
MAVEN_VERSION=3.8.4
wget https://archive.apache.org/dist/maven/maven-3/3.8.4/binaries/apache-maven-3.8.4-bin.tar.gz

# Extract and move Maven to /opt
sudo tar -xvzf apache-maven-${MAVEN_VERSION}-bin.tar.gz -C /opt/
sudo ln -s /opt/apache-maven-${MAVEN_VERSION} /opt/maven

# Update system PATH for Maven
echo "export M2_HOME=/opt/maven" | sudo tee -a /etc/profile.d/maven.sh
echo "export PATH=\$M2_HOME/bin:\$PATH" | sudo tee -a /etc/profile.d/maven.sh
source /etc/profile.d/maven.sh

# Verify Maven installation
mvn -version

# Confirmation message
echo "Maven, Git, and JDK 11 setup is complete!"