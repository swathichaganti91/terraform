#create cust vpc
resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name ="main"
  }

}
resource "aws_subnet" "public" {
  vpc_id = aws_vpc.name.id
  cidr_block = "10.0.1.0/24"
   availability_zone = "ap-south-1a"
   map_public_ip_on_launch = true

   tags = {
    Name = "public-subnet"
   } 
}  
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.name.id
  tags = {
    Name = "igw"

  }
} 
resource "aws_eip" "nat1" {
  domain = "vpc"
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.name.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id

  }
  tags = {
    Name = "publicrt"
  }
  

}
resource "aws_route_table_association" "public_assoc" {
  subnet_id = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

resource "aws_subnet" "private" {
  vpc_id = aws_vpc.name.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"

  tags = {
    Name = "private subnet"
  }
}


resource "aws_route_table" "private" {
    vpc_id = aws_vpc.name.id

    route {
        cidr_block = "0.0.0.0/0"
        nat_gateway_id = aws_nat_gateway.nat1.id
    }
    tags = {
      name = "privatert"
    }
  
}
resource "aws_nat_gateway" "nat1" {
   allocation_id = aws_eip.nat1.id
   subnet_id = aws_subnet.public.id

   tags = {
    Name = "nat-gateway"
   } 

   depends_on = [ aws_internet_gateway.igw ]
}
resource "aws_route_table_association" "private_assoc" {
  subnet_id = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

  

resource "aws_security_group" "web_sg" {
    vpc_id = aws_vpc.name.id
    ingress  {
        description = "SSH"
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
       description = "http"
       from_port = 80
       to_port  = 80
       protocol = "tcp"
       cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
      Name = "web-sg"
    }
  
}
resource "aws_instance" "name" {
    ami = "ami-0d54604676873b4ec"
    instance_type = "t2.micro"
    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.web_sg.id]
    associate_public_ip_address = true

    tags = {
      Name = "ec2instance"
    }
  
}