provider "aws" {
  region = "ap-south-1"
}

# Upload your local public SSH key to AWS as a key pair
resource "aws_key_pair" "my_key" {
  key_name   = "my-ec2-keypair-docker"
  public_key = file("C:/Users/user/.ssh/id_rsa.pub")

  lifecycle {
    ignore_changes = [public_key]
  }
}

resource "aws_vpc" "custom_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "custom-vpc"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.custom_vpc.id

  tags = {
    Name = "custom-igw"
  }
}

resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.custom_vpc.id
  cidr_block              = "10.0.1.0/24"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.custom_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-route-table"
  }
}

resource "aws_route_table_association" "public_subnet_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

resource "aws_security_group" "allow_ssh_docker" {
  name        = "allow_ssh_docker"
  description = "Allow SSH and web ports"
  vpc_id      = aws_vpc.custom_vpc.id

  ingress {
    description = "Allow SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP range 80-86"
    from_port   = 80
    to_port     = 86
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "Allow all outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app_server" {
  ami                         = "ami-0f9708d1cd2cfee41"
  instance_type               = "t3.micro"
  subnet_id                   = aws_subnet.public_subnet.id
  associate_public_ip_address = true
  vpc_security_group_ids      = [aws_security_group.allow_ssh_docker.id]
  #key_name                    = aws_key_pair.my_key.key_name

  tags = {
    Name = "swathi1Server"
  }

  user_data = <<-EOF
              #!/bin/bash
              exec > /var/log/user-data.log 2>&1

              dnf update -y
              dnf install -y docker git
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ec2-user

              mkdir -p /home/ec2-user/.docker/cli-plugins
              curl -SL https://github.com/docker/compose/releases/download/v2.27.0/docker-compose-linux-x86_64 -o /home/ec2-user/.docker/cli-plugins/docker-compose
              chmod +x /home/ec2-user/.docker/cli-plugins/docker-compose

              cd /home/ec2-user
              git clone https://github.com/CloudTechDevOps/2nd10WeeksofCloudOps-main.git
              cd 2nd10WeeksofCloudOps-main
              /home/ec2-user/.docker/cli-plugins/docker-compose up -d
              EOF
}
