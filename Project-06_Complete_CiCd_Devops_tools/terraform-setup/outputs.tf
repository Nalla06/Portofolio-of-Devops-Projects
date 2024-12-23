# Output the VPC ID
output "vpc_id" {
  value = aws_vpc.my_vpc.id
  description = "The ID of the VPC"
}

# Output the subnet IDs
output "subnet_ids" {
  value = [aws_subnet.subnet1.id, aws_subnet.subnet2.id]
  description = "The IDs of the subnets"
}

# Output the public IPs of the Ansible Controller instance
output "ansible_controller_public_ip" {
  value = aws_instance.ansible_controller.public_ip
  description = "The public IP of the Ansible Controller instance"
}

# Output the public IP of the Jenkins Master instance
output "jenkins_master_public_ip" {
  value = aws_instance.jenkins_master.public_ip
  description = "The public IP of the Jenkins Master instance"
}

# Output the public IPs of the Jenkins Agent instances
output "jenkins_agent_public_ips" {
  value = aws_instance.jenkins_agent[*].public_ip
  description = "The public IPs of the Jenkins Agent instances"
}

# Output the Security Group ID for reference
output "security_group_id" {
  value = aws_security_group.allow_ssh_http.id
  description = "The ID of the security group that allows SSH, HTTP, and Jenkins access"
}
