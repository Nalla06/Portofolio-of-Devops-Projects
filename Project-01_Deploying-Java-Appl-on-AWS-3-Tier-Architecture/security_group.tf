# Fetch your public IP dynamically
data "http" "my_ip" {
  url = "https://checkip.amazonaws.com"
}

# Bastion Security Group (SSH only for bastion, limited to your IP)
resource "aws_security_group" "bastion_sg" {
  name        = "bastion_sg"
  description = "Bastion host security group"
  vpc_id      = aws_vpc.public_vpc.id

  # Ingress: Allow SSH from your home IP
  ingress {
    description = "Allow SSH from Home IP"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${trimspace(data.http.my_ip.response_body)}/32"]  # Dynamic IP retrieval
  }

  # Egress: Allow SSH access to Private VPC CIDR (10.0.0.0/16)
  egress {
    description = "Allow SSH to Private VPC CIDR"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # Private VPC CIDR
  }

  # Egress: Allow all other outbound traffic
  egress {
    description = "Allow all other outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
# Nginx Security Group (SSH, Allow HTTP access from my IP)
resource "aws_security_group" "nginx_sg" {
  name        = "nginx_sg"
  description = "Nginx Security Group"
  vpc_id      = aws_vpc.private_vpc.id

  # Allow HTTP access only from our IP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups= [aws_security_group.alb_sg.id]  # Allow ALB to access Nginx instances
  }

  # Allow SSH access from Bastion Host for management
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.bastion_host.private_ip}/32"]
    #cidr_blocks = ["192.168.0.0/16"] # cidr of public vpc 
    #cidr_blocks = ["${aws_instance.bastion_host.public_ip}/32"]   # Bastion Host Public IP only
    #security_groups = [aws_security_group.bastion_sg.id]  # Allow SSH from Bastion Host SG
  }
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # private vpc 
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]  # private vpc
  }

  # Egress: Allow all other outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Tomcat Security Group (No SSH, Allow HTTP access from nginx, also on port 8080)
resource "aws_security_group" "tomcat_sg" {
  name        = "tomcat_sg"
  description = "Tomcat Security Group"
  vpc_id      = aws_vpc.private_vpc.id

  # Allow HTTP access to Tomcat (port 8080) from Nginx
  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    security_groups = [aws_security_group.alb_sg.id]  # Nginx security group
  }

  # Allow SSH from Bastion Host for management
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.bastion_host.private_ip}/32"]
    #cidr_blocks = ["192.168.0.0/16"] 
    #cidr_blocks = ["${aws_instance.bastion_host.public_ip}/32"]  # Bastion Host Public IP only
    #security_groups = [aws_security_group.bastion_sg.id, aws_security_group.nginx_sg.id]
  }

  # Egress: Allow to mysql
  egress {
    description = "Allow MySQL traffic to Database"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # CIDR range of private vpc
  }
}
# Maven Security Group
resource "aws_security_group" "maven_sg" {
  name        = "maven_sg"
  description = "Security group for Maven EC2 instance"
  vpc_id      = aws_vpc.private_vpc.id

  # Inbound rules
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]   # Allow SSH access from Bastion Host security group
  }
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${aws_instance.bastion_host.private_ip}/32"] # publiv vpc 
  }
  # Outbound rules (default is all traffic allowed)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow outbound traffic to anywhere
  }

  tags = {
    Name = "Maven-Security-Group"
  }
}
# MySQL Security Group (Allow access from Tomcat and Nginx only)
resource "aws_security_group" "mysql_sg" {
  name        = "mysql_sg"
  description = "MySQL Security Group"
  vpc_id      = aws_vpc.private_vpc.id

  # Allow MySQL access from Tomcat's and Nginx's Security Groups
  ingress {
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"] # CIDR range of private vpc
  }

  # Allow SSH from nginx, tomcat
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    security_groups = [aws_security_group.nginx_sg.id,aws_security_group.tomcat_sg.id] # public vpc
  }
  # Outbound traffic: Allow updates or patches
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_security_group" "alb_sg" {
  vpc_id = aws_vpc.private_vpc.id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Allow inbound traffic from anywhere
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb_sg"
  }
}

