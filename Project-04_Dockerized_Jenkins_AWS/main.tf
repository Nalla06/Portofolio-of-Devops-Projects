terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Fetch your public IP dynamically for SSH access
data "http" "my_ip" {
  url = "http://checkip.amazonaws.com/"
}

# Retrieve the private key from AWS Parameter Store
data "aws_ssm_parameter" "linux_key_pair" {
  name = "/ssh/linux-key-pair"
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Allow SSH, HTTP, and Jenkins traffic"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"] # Restrict SSH access # Restrict SSH access to your IP
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Jenkins access
  }
  ingress {
    from_port   = 8085
    to_port     = 8085
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # tomcat access
  }
    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP access from anywhere
  }
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow HTTPS access from anywhere (if using SSL/TLS)
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # Allow all outbound traffic
  }
}

resource "aws_instance" "jenkins_server" {
  ami           = "ami-0df8c184d5f6ae949" # Replace with your AMI ID
  instance_type = "t3.medium"
  key_name      = "linux-key-pair"
  user_data     = file("userdata.sh")

  # Associate the security group
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host     = aws_instance.jenkins_server.public_ip # Use the instance's public IP
      user        = "ec2-user"
      private_key = data.aws_ssm_parameter.linux_key_pair.value # Decode the private key
      
    }

    inline = [
      "echo 'Ensuring system is ready for package installation...'",
      "for i in {1..5}; do sudo yum update -y && sudo yum install -y java-17 && break || sleep 10; done"
    ]
  }

  tags = {
    Name = "JenkinsServer"
  }
}

output "jenkins_url" {
  value       = "http://${aws_instance.jenkins_server.public_ip}:8080"
  description = "Access your Jenkins instance at this URL"
}
