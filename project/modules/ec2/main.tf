resource "aws_instance" "bastion" {
  ami                    = "ami-0fe4e90accd5cc34a"
  instance_type          = "t3.micro"
  key_name               = var.key_name
  subnet_id              = var.public_subnet_ids[0]
  vpc_security_group_ids = [var.sg_id]
  associate_public_ip_address = true

  tags = { Name = "bastion-ec2" }
}

resource "aws_instance" "frontend" {
  ami                    = var.frontend_ami   # <-- FIXED
  instance_type          = "t3.micro"
  key_name               = var.key_name
  subnet_id              = var.private_subnet_ids[0]
  vpc_security_group_ids = [var.sg_id]

  tags = { Name = "frontend-ec2" }
}

resource "aws_instance" "backend" {
  ami                    = var.backend_ami    # <-- FIXED
  instance_type          = "t3.micro"
  key_name               = var.key_name
  subnet_id              = var.private_subnet_ids[2]
  vpc_security_group_ids = [var.sg_id]
  iam_instance_profile   = var.backend_instance_profile

  tags = { Name = "backend-ec2" }
}
