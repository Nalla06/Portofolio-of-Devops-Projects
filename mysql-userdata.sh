#!/bin/bash

# Update the system
sudo yum update -y

# Install MySQL (Amazon Linux 2 uses MySQL 8.0)
sudo yum localinstall -y https://dev.mysql.com/get/mysql80-community-release-el7-3.noarch.rpm

# Install MySQL 8.0
sudo yum install -y mysql-community-server

# Enable and start MySQL service
sudo systemctl enable mysqld
sudo systemctl start mysqld

# Get the temporary password for MySQL root user
TEMP_PASSWORD=$(sudo grep 'temporary password' /var/log/mysqld.log | awk '{print $NF}')

# Secure MySQL installation
sudo mysql_secure_installation <<EOF

y
$TEMP_PASSWORD
$TEMP_PASSWORD
y
y
y
y
EOF

# Create a database 
mysql -u root -p$TEMP_PASSWORD -e "CREATE DATABASE myapp_db;"

#  Install CloudWatch agent for monitoring
sudo yum install -y amazon-cloudwatch-agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start

# Install AWS Systems Manager (SSM) Agent for remote management
sudo yum install -y amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent

# Reboot the instance 
sudo reboot
