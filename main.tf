
provider "aws" {
  region = "ap-south-1"
}

resource "aws_instance" "name" {
  ami           = "ami-0d0ad8bb301edb745"
  instance_type = "t2.nano"

  tags = {
    Name = "tedhbcdehvtv"
  }
}

