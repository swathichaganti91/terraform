variable "key_name" {
  type = string
}

variable "public_subnet_ids" {
  type = list(string)
}

variable "private_subnet_ids" {
  type = list(string)
}

variable "sg_id" {
  type = string
}
variable "frontend_ami" {
  type = string
}

variable "backend_ami" {
  type = string
}
variable "backend_instance_profile" {
  type    = string
  default = null
}



