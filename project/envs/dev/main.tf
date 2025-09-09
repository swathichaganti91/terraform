terraform {
  required_version = ">= 1.5"
}

provider "aws" {
  region = "ap-northeast-3"#osaka

}
module "vpc" {
  source = "../../modules/vpc"
}
resource "aws_iam_role" "backend_role" {
  name = "backend-ec2-secrets-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action    = "sts:AssumeRole"
      Effect    = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
}
resource "aws_iam_policy" "secrets_policy" {
  name        = "backend-secrets-policy"
  description = "Allow backend EC2 to read secrets from AWS Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:ap-northeast-3:554930853277:secret:prateek-QcRKKa*"
      }
    ]
  })
}
resource "aws_iam_role_policy_attachment" "backend_secrets_attach" {
  role       = aws_iam_role.backend_role.name
  policy_arn = aws_iam_policy.secrets_policy.arn
}
resource "aws_iam_instance_profile" "backend_profile" {
  name = "backend-ec2-profile"
  role = aws_iam_role.backend_role.name
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
  backend_instance_profile = aws_iam_instance_profile.backend_profile.name  
}
resource "aws_db_subnet_group" "book_subnets" {
  name       = "bookdb-subnet-group"
  subnet_ids = [
    module.vpc.private_subnet_ids[1],
    module.vpc.private_subnet_ids[5]
    ]
  tags = {
    Name = "bookdb-subnet-group"
  }
}

module "rds" {
  source = "../../modules/rds"

  db_identifier         = "book-rds"
  allocated_storage     = "20"
  engine                = "mysql"
  db_name               = "bookdb"
  db_instance_class     = "db.t3.micro"

  db_subnet_group_name  = aws_db_subnet_group.book_subnets.name
  vpc_security_group_ids = [module.vpc.sg_id]

  # Use backend EC2 public IP from module

 backend_public_ip = module.ec2.backend_public_ip
 backend_private_ip = module.ec2.backend_private_ip
 bastion_public_ip  = module.ec2.bastion_public_ip
}



module "compute" {
  source = "../../modules/compute"

  vpc_sg_id               = module.vpc.sg_id
  vpc_id                  = module.vpc.vpc_id
  backend_private_subnets  = [module.vpc.private_subnet_ids[2]]    # subnet3 for backend ASG
  frontend_public_subnets  = [[module.vpc.public_subnet_ids[0], module.vpc.public_subnet_ids[1]]]     # subnet1&2 for frontend ALB
  frontend_private_subnets = [module.vpc.private_subnet_ids[0]]    # subnet1 for frontend ASG

  backend_ami   = "ami-0ea9161deacc4e14b"
  frontend_ami  = "ami-095887f48ad47f389"
  instance_type = var.instance_type
}