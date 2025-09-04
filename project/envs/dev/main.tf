terraform {
  required_version = ">= 1.5"
}

provider "aws" {
  region = "ap-northeast-3"#osaka

}
module "vpc" {
  source = "../../modules/vpc"
}
resource "aws_key_pair" "my_key" {
  key_name   = "my-ec2-keypair"          # will appear in AWS console
  public_key = file("~/.ssh/id_rsa.pub") # local public key
}

module "ec2" {
  source = "../../modules/ec2"

  key_name           = aws_key_pair.my_key.key_name
  public_subnet_ids  = module.vpc.public_subnet_ids
  private_subnet_ids = module.vpc.private_subnet_ids
  sg_id              = module.vpc.sg_id
  frontend_ami = "ami-095887f48ad47f389" # your custom frontend AMI
  backend_ami  = "ami-0ea9161deacc4e14b" # your custom backend AMI
}
#resource "aws_db_subnet_group" "book_subnets" {
#  name       = "bookdb-subnet-group"
#  subnet_ids = [
#    module.vpc.private_subnet_ids]
#  tags = {
#    Name = "bookdb-subnet-group"
#  }
#}

#module "rds" {
#  source = "../../modules/rds"

#  db_identifier         = "book-rds"
#  allocated_storage     = "20"
#  engine                = "mysql"
#  db_name               = "bookdb"
#  db_instance_class     = "db.t3.micro"

#  db_subnet_group_name  = aws_db_subnet_group.book_subnets.name
#  vpc_security_group_ids = [module.vpc.sg_id]

  # Use backend EC2 public IP from module

#  backend_public_ip = module.ec2.backend_public_ip
#}



module "compute" {
  source = "../../modules/compute"

  vpc_sg_id               = module.vpc.sg_id
  vpc_id                  = module.vpc.vpc_id
  backend_private_subnets  = module.vpc.private_subnet_ids
  frontend_public_subnets  = module.vpc.public_subnet_ids
  backend_ami   = "ami-0ea9161deacc4e14b"
  frontend_ami  = "ami-095887f48ad47f389"
  instance_type = var.instance_type
}