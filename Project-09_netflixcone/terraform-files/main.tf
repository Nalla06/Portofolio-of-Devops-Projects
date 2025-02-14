provider "aws" {
  region = "us-east-1" # Change if needed
}

resource "aws_instance" "jenkins_ec2" {
  ami                    = "ami-04b4f1a9cf54c11d0" # Ubuntu 22.04 AMI
  instance_type          = "t2.large"
  key_name               = "linux-key-pair"
  vpc_security_group_ids = [aws_security_group.netflix_sg.id]
  subnet_id              = "subnet-0217a0f00219c07b8" # Replace with your subnet ID
  associate_public_ip_address = true

  tags = {
    Name = "Jenkins-EC2"
  }
}
resource "aws_instance" "prometheus_ec2" {
  ami                    = "ami-04b4f1a9cf54c11d0" # Ubuntu 22.04 AMI
  instance_type          = "t2.medium"  
  key_name               = "linux-key-pair"  
  vpc_security_group_ids = [aws_security_group.prometheus_sg.id]
  subnet_id              = "subnet-0217a0f00219c07b8"  # Replace with your subnet ID
  associate_public_ip_address = true

  tags = {
    Name = "Prometheus-Monitoring-EC2"
  }
}

resource "aws_instance" "k8s_master" {
  ami                    = "ami-04b4f1a9cf54c11d0" # Ubuntu 22.04 AMI
  instance_type          = "t2.medium"
  key_name               = "linux-key-pair"
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  subnet_id              = "subnet-0217a0f00219c07b8" # Replace with your subnet ID
  associate_public_ip_address = true

  tags = {
    Name = "K8s-Master"
  }
}

resource "aws_instance" "k8s_worker" {
  ami                    = "ami-04b4f1a9cf54c11d0" # Ubuntu 22.04 AMI
  instance_type          = "t2.medium"
  key_name               = "linux-key-pair"
  vpc_security_group_ids = [aws_security_group.k8s_sg.id]
  subnet_id              = "subnet-0217a0f00219c07b8" # Replace with your subnet ID
  associate_public_ip_address = true

  tags = {
    Name = "K8s-Worker"
  }
}

output "jenkins_public_ip" {
  value = aws_instance.jenkins_ec2.public_ip
}

output "prometheus_public_ip" {
  description = "Public IP of the Prometheus EC2 instance"
  value       = aws_instance.prometheus_ec2.public_ip
}

output "k8s_master_public_ip" {
  description = "Public IP of the Kubernetes Master EC2 instance"
  value       = aws_instance.k8s_master.public_ip
}

output "k8s_worker_public_ip" {
  description = "Public IP of the Kubernetes Worker EC2 instance"
  value       = aws_instance.k8s_worker.public_ip
}