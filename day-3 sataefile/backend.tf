terraform {
  backend "s3" {
    bucket = "theswathi.shop"
    key = "terraform.tfstate"
    region = "ap-south-1"
    
  }
}