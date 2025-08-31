variable "ami_id" {
    type = string
  
}
variable "instance_type" {
    type = string
    default = "t3.micro"
  
}
variable "public_subnets" {
    description = "list of public subnet ids"
    type = list(string)
    default = [  ]
  
}
variable "vpc_id" {
    type = string
    default = ""

  
}