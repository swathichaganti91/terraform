provider "aws" {
    region = "ap-south-1"
  
}
resource "aws_vpc" "rdsvpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_support = true
  enable_dns_hostnames = true

  tags = {
    Name = "vpc"
  }
}
resource "aws_subnet" "subnet1" {
  vpc_id = aws_vpc.rdsvpc.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
}
resource "aws_subnet" "subnet2" {
  vpc_id = aws_vpc.rdsvpc.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
}
resource "aws_db_subnet_group" "subgrp" {
   name = "my-db-subnet-group"
   subnet_ids = [ aws_subnet.subnet2.id, aws_subnet.subnet1.id ]
}
  
resource "aws_security_group" "mysg" {
  name = "rds_sg"
  description = "allowalltraffic"
  vpc_id = aws_vpc.rdsvpc.id

  ingress  {
    from_port  = 3306
    to_port    = 3306
    protocol   = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress  {
    from_port  = 0
    to_port    = 0
    protocol   = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

   tags = {
     db_Name = "sgwaste"
   }

}


  resource "aws_db_instance" "name" {
    allocated_storage = 20
    storage_type = "gp2"
    engine = "mysql"
    engine_version = "8.0"
    instance_class = "db.t3.micro"
    db_name = "mydatabase"
    username = "adminuser"
    password = "Swathi890!"
    parameter_group_name = "default.mysql8.0"
    skip_final_snapshot = true
    publicly_accessible = true
    multi_az = false
    db_subnet_group_name = aws_db_subnet_group.subgrp.name
    vpc_security_group_ids = [ aws_security_group.mysg.id ]
    backup_retention_period = 7
    delete_automated_backups = true

    tags = {
      Name = "RDSinstance"
    }
    

    
  }

  resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.rdsvpc.id

    tags = {
      Name = "main_igw"
    }
    
  }
  resource "aws_route_table" "publicrt" {
    vpc_id = aws_vpc.rdsvpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id

    }
    
      tags = {
        Name = "route-table"
      }
    
  }

  resource "aws_route_table_association" "subnet1_associations" {
    subnet_id = aws_subnet.subnet1.id

    route_table_id = aws_route_table.publicrt.id
    
  }
  resource "aws_route_table_association" "subnet2_associations" {
    subnet_id = aws_subnet.subnet2.id
    route_table_id = aws_route_table.publicrt.id
    
  }

  #create read replica
  
  resource "aws_db_instance" "replica" {
    identifier = "mydatabase-replica"
    instance_class = "db.t3.micro"
    engine = "mysql"
    publicly_accessible = true
    replicate_source_db = aws_db_instance.name.arn
    db_subnet_group_name = aws_db_subnet_group.subgrp.name
    vpc_security_group_ids = [ aws_security_group.mysg.id ]
    skip_final_snapshot = true
    availability_zone = "ap-south-1b"
    tags = {
      Name = "rds readreplica"
    }
    
  }
