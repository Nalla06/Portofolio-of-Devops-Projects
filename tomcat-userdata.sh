#!/bin/bash
# Update the package manager and install necessary dependencies
sudo yum update -y

# Install Java (required for Tomcat)
sudo yum install java-17 -y

# Change to /usr/local/bin directory to store the application
cd /usr/local/bin

# Download Tomcat binary
TOMCAT_VERSION="11.0.2"
TOMCAT_URL="https://dlcdn.apache.org/tomcat/tomcat-11/v${TOMCAT_VERSION}/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz"
sudo wget $TOMCAT_URL

# Unzip Tomcat binary
sudo tar -zvxf apache-tomcat-${TOMCAT_VERSION}.tar.gz

# Create a Tomcat user and group for security
sudo groupadd tomcat
sudo useradd -M -s /bin/nologin -g tomcat -d /opt/tomcat tomcat

# Move Tomcat to /opt directory
sudo mv apache-tomcat-${TOMCAT_VERSION} /opt/tomcat

# Set ownership for Tomcat directory
sudo chown -R tomcat:tomcat /opt/tomcat

# Start Tomcat once to ensure it's set up correctly
sudo /opt/tomcat/bin/startup.sh

# Configure Tomcat as a systemd service
cat <<EOF | sudo tee /etc/systemd/system/tomcat.service
[Unit]
Description=Apache Tomcat Web Application Container
After=network.target

[Service]
Type=forking

Environment=JAVA_HOME=/usr/lib/jvm/java-17-openjdk
Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
Environment=CATALINA_HOME=/opt/tomcat
Environment=CATALINA_BASE=/opt/tomcat
Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

ExecStart=/opt/tomcat/bin/startup.sh
ExecStop=/opt/tomcat/bin/shutdown.sh

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
rm -rf /usr/local/bin/apache-tomcat-${TOMCAT_VERSION}.tar.gz

# Confirmation message
echo "Tomcat setup is complete!"
