#!/bin/bash
# Update the package manager and install necessary dependencies
sudo yum update -y

# Install Java (required for Tomcat)
sudo yum install java-17 -y

# Change to /opt directory to store the application
cd /opt

# Download Tomcat binary
TOMCAT_VERSION="11.0.2"
TOMCAT_URL="https://dlcdn.apache.org/tomcat/tomcat-11/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"
sudo wget $TOMCAT_URL

# Unzip Tomcat binary
sudo tar -zvxf apache-tomcat-${TOMCAT_VERSION}.tar.gz

# Create a Tomcat user and group for security
sudo groupadd tomcat
sudo useradd -M -s /bin/nologin -g tomcat -d /opt/apache-tomcat-${TOMCAT_VERSION} tomcat

# Set ownership for Tomcat directory and apply necessary permissions
sudo chown -R tomcat:tomcat /opt/apache-tomcat-${TOMCAT_VERSION}
sudo chmod -R 755 /opt/apache-tomcat-${TOMCAT_VERSION}

# Start Tomcat once to ensure it's set up correctly
sudo /opt/apache-tomcat-${TOMCAT_VERSION}/bin/startup.sh

# Configure Tomcat as a systemd service
cat <<EOF | sudo tee /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/java-17-amazon-corretto
Environment=CATALINA_PID=/opt/apache-tomcat-${TOMCAT_VERSION}/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/apache-tomcat-${TOMCAT_VERSION}
Environment=CATALINA_BASE=/opt/apache-tomcat-${TOMCAT_VERSION}
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/apache-tomcat-${TOMCAT_VERSION}/bin/startup.sh
ExecStop=/opt/apache-tomcat-${TOMCAT_VERSION}/bin/shutdown.sh

User=tomcat
Group=tomcat
UMask=0007
RestartSec=10
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd daemon and enable the Tomcat service
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl start tomcat

# Clean up temporary files
rm -rf /opt/apache-tomcat-${TOMCAT_VERSION}.tar.gz

# Confirmation message
echo "Tomcat setup is complete!"