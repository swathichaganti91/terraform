terraform {
  required_version = ">= 1.5"
}

provider "aws" {
  region = var.region
}

##########################
# VPC Module
##########################
module "vpc" {
  source   = "../../modules/vpc"
  vpc_cidr = var.vpc_cidr
  vpc_name = var.vpc_name
}

##########################
# RDS Module
##########################
module "rds" {
  source                 = "../../modules/rds"
  db_identifier          = var.db_identifier
  allocated_storage      = var.allocated_storage
  engine                 = var.engine
  db_name                = var.db_name
  db_subnet_group_name   = module.vpc.db_subnet_group_name
  vpc_security_group_ids = [module.vpc.sg_id]
}

##########################
# EC2 Module
##########################
module "compute" {
  source                = "../../modules/compute"
  ami_id                = var.ami_id
  instance_type         = var.instance_type
  vpc_id                = module.vpc.vpc_id
  public_subnets        = module.vpc.public_subnet_ids
  private_subnets       = module.vpc.private_subnet_ids
  backend_db_endpoint   = module.rds.db_endpoint
  backend_db_user       = module.rds.db_username
  backend_db_pass       = module.rds.db_password
  backend_db_name       = module.rds.db_name
}
