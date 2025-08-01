provider "aws" {
  region = "us-west-2"
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

# Create the VPC
resource "aws_vpc" "new_vpc" {
  cidr_block           = "192.168.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = {
    Name = "new-vpc"
  }
}

# Get availability zones
data "aws_availability_zones" "available" {}

# Create Public Subnet
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.new_vpc.id
  cidr_block              = "192.168.1.0/24"
  availability_zone       = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet"
  }
}

# Create Private Subnets
resource "aws_subnet" "private_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.new_vpc.id
  cidr_block              = cidrsubnet("192.168.0.0/16", 8, count.index + 2) # 192.168.2.0/24 and 192.168.3.0/24
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = false
  tags = {
    Name = "private-subnet-${count.index}"
  }
}

# Create Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.new_vpc.id
  tags = {
    Name = "new-vpc-igw"
  }
}

# Create Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc" # Updated to use 'domain' instead of 'vpc'
}

# Create NAT Gateway
resource "aws_nat_gateway" "nat_gateway" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public_subnet.id
  tags = {
    Name = "new-vpc-nat-gateway"
  }
}

# Create Route Table for Public Subnet
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.new_vpc.id
  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route" "public_internet_route" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "public_route_association" {
  route_table_id = aws_route_table.public_route_table.id
  subnet_id      = aws_subnet.public_subnet.id
}

# Create Route Table for Private Subnets
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.new_vpc.id
  tags = {
    Name = "private-route-table"
  }
}

resource "aws_route" "private_nat_route" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat_gateway.id
}

resource "aws_route_table_association" "private_route_association" {
  count          = 2
  route_table_id = aws_route_table.private_route_table.id
  subnet_id      = aws_subnet.private_subnet[count.index].id
}

# Create EKS Cluster
resource "aws_eks_cluster" "eks_cluster" {
  name     = "game-app-cluster"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    # Use the correct subnets
    subnet_ids = [
      aws_subnet.public_subnet.id,
      aws_subnet.private_subnet[0].id,
      aws_subnet.private_subnet[1].id
    ]
  }
}

# Create Node Group
resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "game-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids = [
    aws_subnet.public_subnet.id,
    aws_subnet.private_subnet[0].id,
    aws_subnet.private_subnet[1].id
  ]
  scaling_config {
    desired_size = 2
    min_size     = 1
    max_size     = 3
  }
}
# Create IAM Role for EKS Cluster
resource "aws_iam_role" "eks_role" {
  name               = "eks-role"
  assume_role_policy = data.aws_iam_policy_document.eks_assume_role.json
}

# Attach policies to EKS Cluster Role
resource "aws_iam_role_policy_attachment" "eks_policy" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy",
    "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  ])
  role       = aws_iam_role.eks_role.name
  policy_arn = each.value
}

# Create IAM Role for EKS Worker Nodes
resource "aws_iam_role" "eks_node_role" {
  name               = "eks-node-role"
  assume_role_policy = data.aws_iam_policy_document.eks_node_assume_role.json
}

# Attach policies to EKS Node Role
resource "aws_iam_role_policy_attachment" "eks_node_policies" {
  for_each = toset([
    "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy",
    "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly",
    "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  ])
  role       = aws_iam_role.eks_node_role.name
  policy_arn = each.value
}

# IAM Policy Document for EKS Role Assumption
data "aws_iam_policy_document" "eks_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }
}

# IAM Policy Document for Node Role Assumption
data "aws_iam_policy_document" "eks_node_assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

# Kubernetes Deployment for the Game App
resource "kubernetes_deployment" "game_app" {
  metadata {
    name      = "2048-game-app"
    namespace = "default"
    labels = { app = "2048-game-app" }
  }

  spec {
    replicas = 2
    selector {
      match_labels = { app = "2048-game-app" }
    }
    template {
      metadata {
        labels = { app = "2048-game-app" }
      }
      spec {
        container {
          name  = "2048-game-app"
          image = "xxxxxx/2048-game-app:latest"
          port {
            container_port = 80
          }
        }
      }
    }
  }
}

# Kubernetes Service for the Game App
resource "kubernetes_service" "game_app_service" {
  metadata {
    name      = "game-2048-app-svc"
    namespace = "default"
  }

  spec {
    selector = { app = "2048-game-app" }
    port {
      protocol = "TCP"
      port     = 80
      target_port = 80
    }
    type = "LoadBalancer"
  }
}
