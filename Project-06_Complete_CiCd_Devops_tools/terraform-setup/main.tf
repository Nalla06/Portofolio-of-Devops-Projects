provider "aws" {
  region = var.aws_region
}


resource "aws_vpc" "my_vpc" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "MyVPC"
  }
}

resource "aws_subnet" "subnet1" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.subnet1_cidr
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1a"
  tags = {
    Name = "Subnet1"
  }
}

resource "aws_subnet" "subnet2" {
  vpc_id     = aws_vpc.my_vpc.id
  cidr_block = var.subnet2_cidr
  map_public_ip_on_launch = true
  availability_zone       = "us-east-1b"
  tags = {
    Name = "Subnet2"
  }
}

resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "MyInternetGateway"
  }
}

resource "aws_route_table" "my_route_table" {
  vpc_id = aws_vpc.my_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.my_igw.id
  }

  tags = {
    Name = "MyRouteTable"
  }
}

resource "aws_route_table_association" "subnet1_association" {
  subnet_id      = aws_subnet.subnet1.id
  route_table_id = aws_route_table.my_route_table.id
}

resource "aws_route_table_association" "subnet2_association" {
  subnet_id      = aws_subnet.subnet2.id
  route_table_id = aws_route_table.my_route_table.id
}


resource "aws_instance" "ansible_controller" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.subnet1.id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/linux-key-pair.pem")  # Key to access EC2 instance
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "\\\\wsl$\\Ubuntu-22.04\\home\\nalla\\.ssh\\my_ssh"  # Path to my_ssh in WSL
    destination = "/home/ec2-user/.ssh/my_ssh"  # Remote path to store the key
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install git -y",
      "mkdir -p ~/.ssh",
      "mv /home/ec2-user/.ssh/my_ssh ~/.ssh/my_ssh",  # Ensure the key is in the correct location
      "chmod 600 ~/.ssh/my_ssh",  # Ensure correct permissions on the private key
      "chmod 700 ~/.ssh",  # Set correct permissions on .ssh directory
      "ssh-keyscan github.com >> ~/.ssh/known_hosts",  # Add GitHub to known hosts
      "git config --global user.name 'Nalla06'",
      "git config --global user.email 'lakshmi.rajyam06@gmail.com'",
      "eval $(ssh-agent -s)",  # Start the SSH agent
      "ssh-add ~/.ssh/my_ssh",  # Add the GitHub key to the SSH agent
      "git config --global core.sshCommand 'ssh -i ~/.ssh/my_ssh'",  # Use my_ssh for GitHub
      "git clone git@github.com:Nalla06/Portofolio-of-Devops-Implementations.git"  # Clone repo
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/linux-key-pair.pem")  # Key for SSH connection to EC2
      host        = self.public_ip
    }
  }

  tags = {
    Name = "AnsibleController"
  }
}

resource "aws_instance" "jenkins_master" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.subnet1.id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/linux-key-pair.pem")  # Key to access EC2 instance
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "\\\\wsl$\\Ubuntu-22.04\\home\\nalla\\.ssh\\my_ssh"  # Path to my_ssh in WSL
    destination = "/home/ec2-user/.ssh/my_ssh"  # Remote path to store the key
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install git -y",
      "mkdir -p ~/.ssh",
      "mv /home/ec2-user/.ssh/my_ssh ~/.ssh/my_ssh",  # Ensure the key is in the correct location
      "chmod 600 ~/.ssh/my_ssh",  # Ensure correct permissions on the private key
      "chmod 700 ~/.ssh",  # Set correct permissions on .ssh directory
      "ssh-keyscan github.com >> ~/.ssh/known_hosts",  # Add GitHub to known hosts
      "git config --global user.name 'Nalla06'",
      "git config --global user.email 'lakshmi.rajyam06@gmail.com'",
      "eval $(ssh-agent -s)",  # Start the SSH agent
      "ssh-add ~/.ssh/my_ssh",  # Add the GitHub key to the SSH agent
      "git config --global core.sshCommand 'ssh -i ~/.ssh/my_ssh'",  # Use my_ssh for GitHub
      "git clone git@github.com:Nalla06/Portofolio-of-Devops-Implementations.git"  # Clone repo
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/linux-key-pair.pem")  # Key for SSH connection to EC2
      host        = self.public_ip
    }
  }

  tags = {
    Name = "JenkinsMaster"
  }
}

resource "aws_instance" "jenkins_agent" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = aws_subnet.subnet1.id
  key_name      = var.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  connection {
    type        = "ssh"
    user        = "ec2-user"
    private_key = file("~/.ssh/linux-key-pair.pem")  # Key to access EC2 instance
    host        = self.public_ip
  }

  provisioner "file" {
    source      = "\\\\wsl$\\Ubuntu-22.04\\home\\nalla\\.ssh\\my_ssh"  # Path to my_ssh in WSL
    destination = "/home/ec2-user/.ssh/my_ssh"  # Remote path to store the key
  }

  provisioner "remote-exec" {
    inline = [
      "sudo yum install git -y",
      "mkdir -p ~/.ssh",
      "mv /home/ec2-user/.ssh/my_ssh ~/.ssh/my_ssh",  # Ensure the key is in the correct location
      "chmod 600 ~/.ssh/my_ssh",  # Ensure correct permissions on the private key
      "chmod 700 ~/.ssh",  # Set correct permissions on .ssh directory
      "ssh-keyscan github.com >> ~/.ssh/known_hosts",  # Add GitHub to known hosts
      "git config --global user.name 'Nalla06'",
      "git config --global user.email 'lakshmi.rajyam06@gmail.com'",
      "eval $(ssh-agent -s)",  # Start the SSH agent
      "ssh-add ~/.ssh/my_ssh",  # Add the GitHub key to the SSH agent
      "git config --global core.sshCommand 'ssh -i ~/.ssh/my_ssh'",  # Use my_ssh for GitHub
      "git clone git@github.com:Nalla06/Portofolio-of-Devops-Implementations.git"  # Clone repo
    ]

    connection {
      type        = "ssh"
      user        = "ec2-user"
      private_key = file("~/.ssh/linux-key-pair.pem")  # Key for SSH connection to EC2
      host        = self.public_ip
    }
  }

  tags = {
    Name = "JenkinsAgent"
  }
}

resource "aws_security_group" "allow_ssh_http" {
  vpc_id = aws_vpc.my_vpc.id

  # Allow SSH access
  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow HTTP access
  ingress {
    description = "Allow HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow Jenkins access
  ingress {
    description = "Allow Jenkins"
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Allow outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "AllowSSHHTTPAndJenkins"
  }
}
