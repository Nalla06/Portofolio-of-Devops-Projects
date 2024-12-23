# Define the AWS region
variable "aws_region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1" # Change if needed
}
variable "key_name" {
  description = "Name of the AWS key pair"
  default     = "linux-key-pair"
}


# Define the VPC CIDR block
variable "vpc_cidr" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "192.168.0.0/16"
}

# Define the subnet CIDR blocks
variable "subnet1_cidr" {
  description = "The CIDR block for Subnet1"
  type        = string
  default     = "192.168.1.0/24"
}

variable "subnet2_cidr" {
  description = "The CIDR block for Subnet2"
  type        = string
  default     = "192.168.2.0/24"
}


# Define the AMI ID
variable "ami_id" {
  description = "The AMI ID for the instances"
  type        = string
  default     = "ami-0166fe664262f664c" # Replace with a preferred AMI
}

# Define the instance type
variable "instance_type" {
  description = "The instance type for the instances"
  type        = string
  default     = "t2.medium"
}

# Define the number of Jenkins agents
variable "jenkins_agent_count" {
  description = "The number of Jenkins agent instances"
  type        = number
  default     = 1
}

# SSH key paths
variable "public_key_path" {
  description = "Path to the SSH public key file"
  type        = string
  default     = "~/.ssh/linux-key-pair.pub"
}

variable "private_key_path" {
  description = "Path to the SSH private key file"
  type        = string
  default     = "~/.ssh/linux-key-pair.pem"
}

# GitHub configuration
variable "github_repo" {
  description = "The GitHub repository to clone"
  type        = string
  default     = "git@github.com:Nalla06/Portofolio-of-Devops-Implementations.git" # Replace with actual repo URL
}

variable "github_user" {
  description = "The GitHub username for the repo"
  type        = string
  default     = "" # Replace with your GitHub username
}

variable "github_ssh_public_key" {
  description = " GitHub SSH public key to add to instances"
  type        = string
  validation {
    condition     = length(var.github_ssh_public_key) == 0 || startswith(var.github_ssh_public_key, "ssh-")
    error_message = "The GitHub SSH public key must start with 'ssh-' if provided."
  }
}
