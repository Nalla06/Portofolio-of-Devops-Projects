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

# Create Two VPCs (Public and Private)
resource "aws_vpc" "public_vpc" {
  cidr_block = "192.168.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "Public-VPC"
  }
}

resource "aws_vpc" "private_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "Private-VPC"
  }
}

# Public Subnet in private vpc 
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.public_vpc.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-Subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.public_vpc.id
  cidr_block              = "192.168.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Public-Subnet-2"
  }
}

# Update Public Subnets in Private VPC (Public Subnets that will host NAT Gateway)
resource "aws_subnet" "public_subnet_3" {
  vpc_id                  = aws_vpc.private_vpc.id  # Now part of the private VPC
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Private-Public-Subnet-3"
  }
}

resource "aws_subnet" "public_subnet_4" {
  vpc_id                  = aws_vpc.private_vpc.id  # Now part of the private VPC
  cidr_block              = "10.0.5.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "Private-Public-Subnet-4"
  }
}

# Private Subnets in Two AZs
resource "aws_subnet" "private_subnet_1" {
  vpc_id            = aws_vpc.private_vpc.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"
  map_public_ip_on_launch = false
  tags = {
    Name = "Private-Subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id            = aws_vpc.private_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-east-1b"
  map_public_ip_on_launch = false
  tags = {
    Name = "Private-Subnet-2"
  }
}
resource "aws_internet_gateway" "public_igw" {
  vpc_id = aws_vpc.public_vpc.id
  tags = {
    Name = "public-IGW"
  }
}

# Internet Gateway for private VPC
resource "aws_internet_gateway" "private_igw" {
  vpc_id = aws_vpc.private_vpc.id
  tags = {
    Name = "private-IGW"
  }
}
# NAT Gateway for Private VPC
resource "aws_eip" "nat_eip" {
 #vpc = true
  tags = {
    Name = "NAT-EIP"
  }
}

resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat_eip.id  # Elastic IP for the NAT Gateway
  subnet_id     = aws_subnet.public_subnet_3.id  # Subnet where NAT Gateway will be created
  depends_on    = [aws_internet_gateway.private_igw]
  tags = {
    Name = "NAT-Gateway"
  }
}



# Route Table for Public VPC
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.public_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.public_igw.id
  }
  # Route for Private VPC (private vpc) access via Transit Gateway
  route {
    cidr_block = "10.0.0.0/16" # Replace with the CIDR block of private vpc
    transit_gateway_id = aws_ec2_transit_gateway.main_tgw.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

# Route Table for Private VPC
resource "aws_route_table" "private_vpc_public_subnet_route_table" {
  vpc_id = aws_vpc.private_vpc.id
  # Route for Local Traffic within private vpc
  #route {
  #cidr_block = "10.0.0.0/16" # CIDR range of private VPC
  #gateway_id = "local"       # Default route for local VPC communication
#}
  # Internet access via private internet Gateway
  route {
    cidr_block     = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.private_igw.id
  }
  route {
    cidr_block = "192.168.0.0/16" # CIDR range of public vpc
    transit_gateway_id = aws_ec2_transit_gateway.main_tgw.id
  }
  tags = {
    Name = "Private-VPC-Public-Subnet-Route-Table"
  }
}

resource "aws_route_table" "private_vpc_private_subnet_route_table" {
  vpc_id = aws_vpc.private_vpc.id

  # Route for Local Traffic within private vpc
  #route {
    #cidr_block = "10.0.0.0/16" # CIDR range of private vpc
    #gateway_id = "local"       # Default route for local VPC communication
  #}
  # Route for Traffic to Public VPC (VPC-A) via Transit Gateway
  route {
    cidr_block = "192.168.0.0/16" # CIDR range of public vpc
    transit_gateway_id = aws_ec2_transit_gateway.main_tgw.id
  }
  # Route to NAT Gateway in the Public Subnet of the Private VPC
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat_gateway.id
  }

  tags = {
    Name = "Private-VPC-Private-Subnet-Route-Table"
  }
}
# Associate Public Subnets with Public Route Table
resource "aws_route_table_association" "public_subnet_1_assoc" {
  subnet_id      = aws_subnet.public_subnet_1.id
  route_table_id = aws_route_table.public_route_table.id
}

resource "aws_route_table_association" "public_subnet_2_assoc" {
  subnet_id      = aws_subnet.public_subnet_2.id
  route_table_id = aws_route_table.public_route_table.id
}

# Associate Private Subnets with Private Route Table
resource "aws_route_table_association" "private_subnet_1_assoc" {
  subnet_id      = aws_subnet.private_subnet_1.id
  route_table_id = aws_route_table.private_vpc_private_subnet_route_table.id
}
resource "aws_route_table_association" "private_subnet_2_assoc" {
  subnet_id      = aws_subnet.private_subnet_2.id
  route_table_id = aws_route_table.private_vpc_private_subnet_route_table.id
}
resource "aws_route_table_association" "public_subnet_3_assoc" {
  subnet_id      = aws_subnet.public_subnet_3.id
  route_table_id = aws_route_table.private_vpc_public_subnet_route_table.id
}
resource "aws_route_table_association" "public_subnet_4_assoc" {
  subnet_id      = aws_subnet.public_subnet_4.id
  route_table_id = aws_route_table.private_vpc_public_subnet_route_table.id
}
# Create Transit Gateway
resource "aws_ec2_transit_gateway" "main_tgw" {
  description         = "Main Transit Gateway"
  auto_accept_shared_attachments = "enable"

  default_route_table_association = "enable"
  default_route_table_propagation = "enable"
  
  tags = {
    Name = "Main-Transit-Gateway"
  }
}

# Transit Gateway Attachment for Public VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "public_vpc_attachment" {
  subnet_ids         = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
  transit_gateway_id = aws_ec2_transit_gateway.main_tgw.id
  vpc_id             = aws_vpc.public_vpc.id

  tags = {
    Name = "Public-VPC-Attachment"
  }
}

# Transit Gateway Attachment for Private VPC
resource "aws_ec2_transit_gateway_vpc_attachment" "private_vpc_attachment" {
  subnet_ids         = [
    #aws_subnet.public_subnet_3.id,   # Public subnet in AZ 1
    #aws_subnet.public_subnet_4.id,   # Public subnet in AZ 2
    aws_subnet.private_subnet_1.id,  # Private subnet in AZ 1
    aws_subnet.private_subnet_2.id   # Private subnet in AZ 2
  ]
  transit_gateway_id = aws_ec2_transit_gateway.main_tgw.id
  vpc_id             = aws_vpc.private_vpc.id

  tags = {
    Name = "Private-VPC-Attachment"
  }
}

# Add routes in the Public Route Table to use Transit Gateway
#resource "aws_route" "public_to_private" {
  #route_table_id         = aws_route_table.public_route_table.id
  #destination_cidr_block = "10.0.0.0/16"  # Private VPC CIDR block
  #transit_gateway_id     = aws_ec2_transit_gateway.main_tgw.id
#}

#resource "aws_route" "private_to_internet" {
  #route_table_id         = aws_route_table.private_vpc_private_subnet_route_table.id
  #destination_cidr_block = "0.0.0.0/0" # Internet-bound traffic
  #nat_gateway_id         = aws_nat_gateway.nat_gateway.id
#}

# Add routes in the Private Route Table to use Transit Gateway
#resource "aws_route" "private_to_public" {
  #route_table_id         = aws_route_table.private_vpc_public_subnet_route_table.id
  ##destination_cidr_block = "192.168.0.0/16"  # Public VPC CIDR block
  #transit_gateway_id     = aws_ec2_transit_gateway.main_tgw.id
#}

# Common IAM Role for EC2 Instances
resource "aws_iam_role" "ec2_common_role" {
  name               = "ec2-common-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Effect    = "Allow"
        Sid       = ""
      }
    ]
  })
}
data "aws_caller_identity" "current" {}
# Common IAM Policy for EC2 Instances (SSM, CloudWatch, etc.)
resource "aws_iam_policy" "ec2_common_policy" {
  name        = "ec2-common-policy"
  description = "Policy for EC2 instances to access SSM, CloudWatch, and other services"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "ssm:GetParameter",
          "ssm:DescribeParameters",
          "cloudwatch:PutMetricData",
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogStreams"
        ]
        Resource = [
          "arn:aws:ssm:*:${data.aws_caller_identity.current.account_id}:*",
          "arn:aws:cloudwatch:*:${data.aws_caller_identity.current.account_id}:*",
          "arn:aws:logs:*:${data.aws_caller_identity.current.account_id}:*"
        ]
      }
    ]
  })
}

# Attach the policy to the common IAM role
resource "aws_iam_role_policy_attachment" "ec2_common_policy_attachment" {
  role       = aws_iam_role.ec2_common_role.name
  policy_arn = aws_iam_policy.ec2_common_policy.arn
}
# Create IAM Instance Profile for EC2 instances
resource "aws_iam_instance_profile" "ec2_common_instance_profile" {
  name = "ec2-common-instance-profile"
  role = aws_iam_role.ec2_common_role.name
}
# Bastion Host Configuration
resource "aws_instance" "bastion_host" {
  ami           = "ami-0ca9fb66e076a6e32"
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.public_subnet_1.id
  security_groups = [aws_security_group.bastion_sg.id]
  key_name      = "linux-key-pair"
  user_data     = base64encode(file("bastion-userdata.sh"))
  iam_instance_profile   = aws_iam_instance_profile.ec2_common_instance_profile.name  # Attach the common IAM role to EC2 instance

  tags = {
    Name = "Bastion-Host"
  }

  associate_public_ip_address = true # Ensure the Bastion Host has a public IP
}

# Launch Template for Nginx Instances
resource "aws_launch_template" "nginx_lt" {
  name          = "nginx-launch-template"
  image_id      = "ami-0ca9fb66e076a6e32" # Replace with actual AMI ID
  instance_type = "t3.micro"
  key_name      = "linux-key-pair"
  vpc_security_group_ids = [aws_security_group.nginx_sg.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_common_instance_profile.name
  }
  user_data = base64encode(file("nginx-userdata.sh"))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Nginx-Instance"
    }
  }
}

# Auto Scaling Group for Nginx
resource "aws_autoscaling_group" "nginx_asg" {
  desired_capacity    = 1
  max_size            = 5
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
  
  launch_template {
    id      = aws_launch_template.nginx_lt.id
    version = "$Latest"
  }

  health_check_type        = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "Nginx-Instance"
    propagate_at_launch = true
  }

  # Target Group Registration (handled automatically)
  target_group_arns = [aws_lb_target_group.nginx_target_group.arn]
}

# Target Group for Nginx Load Balancer
resource "aws_lb_target_group" "nginx_target_group" {
  name     = "nginx-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.private_vpc.id

  health_check {
    healthy_threshold   = 3
    interval            = 30
    path                = "/"
    port                = "80"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }

  tags = {
    Name = "nginx-target-group"
  }
}
# Load Balancer for Tomcat, nginx
resource "aws_lb" "my_alb"  {
  name               = "my-app-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public_subnet_3.id, aws_subnet.public_subnet_4.id]
  enable_deletion_protection = false
}
resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.my_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "fixed-response"
    fixed_response {
      status_code = 200
      message_body = "Welcome to the app!"
      content_type = "text/plain"  # Add the content_type attribute here
    }
  }
}

resource "aws_lb_listener_rule" "nginx_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.nginx_target_group.arn
  }

  condition {
  path_pattern {
    values = ["/nginx/*"]
    }
  }
}

resource "aws_lb_listener_rule" "tomcat_rule" {
  listener_arn = aws_lb_listener.http_listener.arn
  priority     = 20

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tomcat_target_group.arn
  }

  condition {
  path_pattern {
    values = ["/tomcat/*"]
  }
}
}

# Launch Template for Tomcat Instances
resource "aws_launch_template" "tomcat_lt" {
  name          = "tomcat-launch-template"
  image_id      = "ami-0ca9fb66e076a6e32" # Replace with your Tomcat AMI ID
  instance_type = "t3.micro"
  key_name      = "linux-key-pair"
  vpc_security_group_ids = [aws_security_group.tomcat_sg.id]
  iam_instance_profile {
    name = aws_iam_instance_profile.ec2_common_instance_profile.name
  }
  user_data = base64encode(file("tomcat-userdata.sh"))

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "Tomcat-Instance"
    }
  }
}

# Auto Scaling Group for Tomcat
resource "aws_autoscaling_group" "tomcat_asg" {
  desired_capacity    = 1
  max_size            = 5
  min_size            = 1
  vpc_zone_identifier = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]

  launch_template {
    id      = aws_launch_template.tomcat_lt.id
    version = "$Latest"
  }

  health_check_type        = "ELB"
  health_check_grace_period = 300

  tag {
    key                 = "Name"
    value               = "Tomcat-Instance"
    propagate_at_launch = true
  }

  target_group_arns = [aws_lb_target_group.tomcat_target_group.arn]
}

# Target Group for Tomcat Load Balancer
resource "aws_lb_target_group" "tomcat_target_group" {
  name     = "tomcat-target-group"
  port     = 8080
  protocol = "HTTP"
  vpc_id   = aws_vpc.private_vpc.id

  health_check {
    healthy_threshold   = 3
    interval            = 30
    path                = "/"
    port                = "8080"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 3
  }

  tags = {
    Name = "tomcat-target-group"
  }
}

# Maven reosurce
resource "aws_instance" "maven" {
  ami           = "ami-0ca9fb66e076a6e32"  # Replace with appropriate AMI for your region
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private_subnet_2.id  # Assign to private subnet in private VPC
  security_groups = [aws_security_group.maven_sg.id]  # Security Group for Maven instance
  key_name      = "linux-key-pair"  # SSH key pair to access the EC2 instance
  user_data     = base64encode(file("maven-userdata.sh"))  # User data script to configure Maven
  iam_instance_profile   = aws_iam_instance_profile.ec2_common_instance_profile.name  # Attach the common IAM role
  tags = {
    Name = "Maven-Instance"
  }
}
# MySQL EC2 Instance Configuration (Private Subnet)
resource "aws_instance" "mysql" {
  ami           = "ami-0ca9fb66e076a6e32"  # Replace with actual AMI ID
  instance_type = "t3.micro"
  subnet_id     = aws_subnet.private_subnet_1.id  # Use private_subnet_1 or private_subnet_2
  security_groups = [aws_security_group.mysql_sg.id]
  key_name      = "linux-key-pair"  # Replace with your key pair name
  user_data     = base64encode(file("mysql-userdata.sh"))
  iam_instance_profile   = aws_iam_instance_profile.ec2_common_instance_profile.name  # Attach the common IAM role to EC2 instance
  
  tags = {
    Name = "MySQL-Instance"
  }
}

# Outputs (Public IPs of Instances)
output "bastion_public_ip" {
  description = "Public IP of the Bastion Host"
  value       = aws_instance.bastion_host.public_ip
}


output "load_balancer_dns_name" {
  description = "DNS Name of the Load Balancer"
  value       = aws_lb.my_alb.dns_name
}
output "transit_gateway_id" {
  description = "ID of the Transit Gateway"
  value       = aws_ec2_transit_gateway.main_tgw.id
}

output "public_vpc_attachment_id" {
  description = "ID of the Transit Gateway attachment to Public VPC"
  value       = aws_ec2_transit_gateway_vpc_attachment.public_vpc_attachment.id
}

output "private_vpc_attachment_id" {
  description = "ID of the Transit Gateway attachment to Private VPC"
  value       = aws_ec2_transit_gateway_vpc_attachment.private_vpc_attachment.id
}
output "bastion_private_ip" {
  value = aws_instance.bastion_host.private_ip
}
output "my_ip" {
  value = "${trimspace(data.http.my_ip.response_body)}/32"
}
output "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = aws_lb.my_alb.arn
}

output "alb_zone_id" {
  description = "The Zone ID of the Application Load Balancer"
  value       = aws_lb.my_alb.zone_id
}