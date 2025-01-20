#!/bin/bash

# Update the system
sudo yum update -y

# Install AWS CLI (if necessary)
sudo yum install -y aws-cli

# Install additional packages (example installing Vim nano )
sudo yum install -y vim htop nano

# Set up a directory for SSH keys (optional)
mkdir -p /home/ec2-user/.ssh
chmod 700 /home/ec2-user/.ssh

# Retrieve the SSH public key from SSM Parameter Store
SSH_PUBLIC_KEY=$(aws ssm get-parameter --name "/ssh/linux-key-pair.pem" --with-decryption --query "Parameter.Value" --output text)

# Add the public key to the authorized_keys file to allow SSH access
echo "$SSH_PUBLIC_KEY" | sudo tee /home/ec2-user/.ssh/authorized_keys

# Retrieve the SSH private key from SSM Parameter Store (add this step)
SSH_PRIVATE_KEY=$(aws ssm get-parameter --name "/ssh/linux-key-pair.pem" --with-decryption --query "Parameter.Value" --output text)

# Copy the private key to the .ssh directory on Bastion Host
echo "$SSH_PRIVATE_KEY" | sudo tee /home/ec2-user/.ssh/linux-key-pair.pem

# Change ownership and permissions to secure the .ssh directory
sudo chmod 400 /home/ec2-user/.ssh/linux-key-pair.pem
sudo chmod 600 /home/ec2-user/.ssh/authorized_keys
sudo chown -R ec2-user:ec2-user /home/ec2-user/.ssh


# Enable SSH service to ensure it's running
sudo systemctl enable sshd
sudo systemctl start sshd

# Enable and start the HTTP service (optional, if you want a web server on Bastion)
sudo yum install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd

# Install CloudWatch Logs agent (optional, for monitoring and logging)
sudo yum install -y awslogs
sudo systemctl enable awslogs
sudo systemctl start awslogs

# Install CloudWatch Agent for system-level monitoring
sudo yum install -y amazon-cloudwatch-agent
sudo /opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a start

# Install AWS Systems Manager (SSM) Agent for remote management
sudo yum install -y amazon-ssm-agent
sudo systemctl start amazon-ssm-agent
sudo systemctl enable amazon-ssm-agent

# Reboot the instance if necessary (uncomment if required)
sudo reboot

