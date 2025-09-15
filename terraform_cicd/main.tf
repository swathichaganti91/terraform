provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "dev" {
    ami = "ami-0b982602dbb32c5bd"
    instance_type = "t2.micro"
    tags = {
      Name = "prodfff123"
    }
}
