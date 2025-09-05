







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

variable "vpc_sg_id" {
  description = "Security group ID for all instances"
  type        = string
}

variable "backend_private_subnets" {
  description = "List of private subnet IDs for backend"
  type        = list(string)
}

variable "frontend_public_subnets" {
  description = "List of public subnet IDs for frontend"
  type        = list(string)
}

variable "vpc_id" {
  description = "VPC ID"
  type        = string
}
