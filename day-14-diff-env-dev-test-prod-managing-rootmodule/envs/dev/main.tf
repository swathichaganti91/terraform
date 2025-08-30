provider "aws" {
  region = var.region
}

# ────────── VPC & Subnets ──────────
module "vpc" {
  source      = "../../modules/vpc"
  vpc_cidr    = var.vpc_cidr
  vpc_name    = var.vpc_name
  subnet_cidr = var.subnet_cidr
  subnet_az   = var.subnet_az
}

# ────────── EC2 in Public Subnet ──────────
module "ec2" {
  source        = "../../modules/ec2"
  instance_type = var.instance_type
  ami_id        = var.ami_id
  subnet_id     = module.vpc.public_subnet_id   # only first subnet is public
}

# ────────── RDS in Private Subnets ──────────
module "rds" {
  source          = "../../modules/rds"
  db_username     = var.db_username
  db_password     = var.db_password
  subnet_group_id = module.vpc.db_subnet_group
  vpc_id          = module.vpc.vpc_id
}
