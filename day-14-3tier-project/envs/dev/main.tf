terraform {
  required_version = ">= 1.5"
}

provider "aws" {
  region = "ap-northeast-3"#osaka

}
#resource "aws_key_pair" "my_key" {
#  key_name   = "my-ec2-keypair"
#  public_key = file("~/.ssh/id_rsa.pub") # make sure this file exists
#}


##########################
# VPC Module
##########################
module "vpc" {
  source = "../../modules/vpc"
  #vpc_cidr  = "10.0.0.0/16"
  #vpc_name  = "dev-vpc"

  #public_subnet_cidrs = ["10.0.1.0/24", "10.0.4.0/24"]
  #private_subnet_cidrs = ["10.0.2.0/24", "10.0.3.0/24", "10.0.5.0/24"]
  #availability_zones   = ["ap-south-1a", "ap-south-1b", "ap-south-1c"]
}


##########################
# EC2 Module
##########################
#module "compute" {
 # #source        = "../../modules/compute"
  #a#mi_id        = "ami-0861f4e788f5069dd"
  #instance_type = "t3.micro"
  #vpc_id        = module.vpc.vpc_id
  #public_subnets = module.vpc.public_subnet_ids
#}

#module "rds" {
 # source = "../../modules/rds"
  
#}
module "ec2" {
  source = "../../modules/ec2"

  key_name           = "my_ec2_keypair"
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  sg_id              = module.vpc.sg_id
  frontend_ami = "ami-095887f48ad47f389" # your custom frontend AMI
  backend_ami  = "ami-0ea9161deacc4e14b" # your custom backend AMI
}


