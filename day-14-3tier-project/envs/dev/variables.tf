# AWS Region
variable "region" {
  description = "AWS Region"
  type        = string
  default     = "ap-south-1"
}

# VPC
variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "vpc_name" {
  type    = string
  default = "dev-vpc"
}

# RDS
variable "db_identifier" {
  type    = string
  default = "dev-book-rds"
}

variable "allocated_storage" {
  type    = number
  default = 20
}

variable "engine" {
  type    = string
  default = "mysql"
}

variable "db_name" {
  type    = string
  default = "bookdb"
}

# EC2
variable "ami_id" {
  type    = string
  default = "ami-0861f4e788f5069dd"
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}
variable "subnet_cidr" {
  type    = list(string)
  default = [ "10.0.8.0/24" ]
  
}