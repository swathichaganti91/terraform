variable "vpc_security_group_ids" {
  description = "List of security group IDs for RDS"
  type        = list(string)
  
}
variable "backend_ami" {
  description = "AMI ID for backend"
  type        = string
}

variable "frontend_ami" {
  description = "AMI ID for frontend"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}
variable "backend_private_subnets" {
  description = "List of private subnet IDs for backend ASG"
  type        = list(string)
}

variable "frontend_public_subnets" {
  description = "List of public subnet IDs for frontend ASG"
  type        = list(string)
}

