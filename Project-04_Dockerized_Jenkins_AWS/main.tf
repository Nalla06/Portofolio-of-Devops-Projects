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
    cidr_blocks = ["${chomp(data.http.my_ip.response_body)}/32"] # Allow SSH only from your IP
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Jenkins access
  }
    ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow HTTP access from anywhere
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
  instance_type = "t2.micro"
  key_name      = "linux-key-pair"
  user_data     = file("userdata.sh")

  # Associate the security group
  vpc_security_group_ids = [aws_security_group.jenkins_sg.id]

  provisioner "remote-exec" {
    connection {
      type        = "ssh"
      host        = self.public_ip # Use the instance's public IP
      user        = "ec2-user"
      private_key = data.aws_ssm_parameter.linux_key_pair.value
    }

    inline = [
      "echo Hello from Jenkins setup!",
      "sudo yum install -y java-17", # Example: Install Java
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
