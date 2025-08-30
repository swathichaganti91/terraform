resource "aws_vpc" "myvpc" {
    cidr_block = var.vpc_cidr
    enable_dns_hostnames = true
    enable_dns_support   = true

    tags = {
      Name = var.vpc_name
    }
  
}
resource "aws_subnet" "public1" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.1.0/24"
    availability_zone = "ap-south-1a"
    map_public_ip_on_launch = true

    tags = {
        Name = "public1"
    }
  
}
resource "aws_subnet" "public2" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.4.0/24"
    availability_zone = "ap-south-1b"
    map_public_ip_on_launch = true
  
}
resource "aws_subnet" "private1" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.2.0/24"
    availability_zone = "ap-south-1c"

  
}
resource "aws_subnet" "private2" {
    vpc_id = aws_vpc.myvpc.id
    cidr_block = "10.0.3.0/24"
    availability_zone = "ap-south-1b"
  
}
resource "aws_subnet" "private3" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.5.0/24"
  availability_zone = "ap-south-1b"
  
}
resource "aws_subnet" "private4" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.6.0/24"
  availability_zone = "ap-south-1c"
  
}
resource "aws_subnet" "private5" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.7.0/24"
  availability_zone = "ap-south-1a"
  
}
resource "aws_subnet" "private6" {
  vpc_id = aws_vpc.myvpc.id
  cidr_block = "10.0.7.0/24"
  availability_zone = "ap-south-1a"
  
}
resource "aws_db_subnet_group" "subgroup" {
    subnet_ids = [aws_subnet.private1.id, aws_subnet.private2.id]
  
}
resource "aws_security_group" "sg" {
    vpc_id = aws_vpc.myvpc.id

    dynamic "ingress" {
    for_each = toset([22, 3306, 3000, 443, 9100, 9090, 5000])
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["10.0.0.0/16"]
    }
  }

  # Outbound to anywhere
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


  
