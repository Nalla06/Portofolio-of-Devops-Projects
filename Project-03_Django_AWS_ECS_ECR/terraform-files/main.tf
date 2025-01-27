provider "aws" {
  region = "us-east-1"
}

# Create a VPC
resource "aws_vpc" "django_vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "django-vpc"
  }
}

# Create public subnets for ECS instances and ALB
resource "aws_subnet" "public_subnet_1" {
  vpc_id                  = aws_vpc.django_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-1"
  }
}

resource "aws_subnet" "public_subnet_2" {
  vpc_id                  = aws_vpc.django_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-2"
  }
}

# Create private subnets for ECS service tasks (optional)
resource "aws_subnet" "private_subnet_1" {
  vpc_id                  = aws_vpc.django_vpc.id
  cidr_block              = "10.0.3.0/24"
  availability_zone       = "us-east-1a"
  tags = {
    Name = "private-subnet-1"
  }
}

resource "aws_subnet" "private_subnet_2" {
  vpc_id                  = aws_vpc.django_vpc.id
  cidr_block              = "10.0.4.0/24"
  availability_zone       = "us-east-1b"
  tags = {
    Name = "private-subnet-2"
  }
}

# Create an Internet Gateway for the VPC
resource "aws_internet_gateway" "django_igw" {
  vpc_id = aws_vpc.django_vpc.id
  tags = {
    Name = "django-igw"
  }
}

# Create an ECR repository for the Django app
resource "aws_ecr_repository" "django_ecr" {
  name = "django-app-repo"
}

# Create an ECS Cluster for running the containerized Django app
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "django-cluster"
}

# Create IAM role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Effect   = "Allow"
        Sid      = ""
      }
    ]
  })
}

# Attach ECS Task Execution policy to the role
resource "aws_iam_role_policy_attachment" "ecs_task_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECSTaskExecutionRolePolicy"
}

# Create ECS Task Definition for Django app
resource "aws_ecs_task_definition" "django_task" {
  family                   = "django-task"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  container_definitions    = jsonencode([{
    name      = "django-container"
    image     = "${aws_ecr_repository.django_ecr.repository_url}:latest"
    memory    = 512
    cpu       = 256
    essential = true
    portMappings = [{
      containerPort = 8000
      hostPort      = 80
      protocol      = "tcp"
    }]
  }])
}

# Create Application Load Balancer (ALB)
resource "aws_lb" "django_lb" {
  name               = "django-lb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.lb_sg.id] 
  subnets            = [aws_subnet.public_subnet_1.id, aws_subnet.public_subnet_2.id]
}

# Create Target Group for ALB
resource "aws_lb_target_group" "django_target_group" {
  name     = "django-target-group"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.django_vpc.id
}

# Create Listener for the ALB
resource "aws_lb_listener" "django_listener" {
  load_balancer_arn = aws_lb.django_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.django_target_group.arn
  }
}

# Create ECS Service for Django application
resource "aws_ecs_service" "django_service" {
  name            = "django-service"
  cluster         = aws_ecs_cluster.ecs_cluster.id
  task_definition = aws_ecs_task_definition.django_task.arn
  desired_count   = 2

  network_configuration {
    subnets          = [aws_subnet.private_subnet_1.id, aws_subnet.private_subnet_2.id]
    security_groups  = [aws_security_group.ecs_service_sg.id] # Replace with your security group ID
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.django_target_group.arn
    container_name   = "django-container"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.django_listener]
}

# Output the ECR repository URL for Docker image push
output "ecr_repository_url" {
  value = aws_ecr_repository.django_ecr.repository_url
}
