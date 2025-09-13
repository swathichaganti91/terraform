variable "db_instance_class" {
    type = string
    default = "db.t3.micro"
  
}
variable "db_identifier" {
    type = string
    default = "book-rds"
  
}
variable "allocated_storage" {
  type = string
  default = "20"
}
variable "engine" {
    type = string
    default = "mysql"
  
}
variable "db_name" {
    type = string
    default = "bookdb"
  
}
variable "username" {
    type = string
    default = ""
  

}
variable "password" {
    type = string
    default = ""
    sensitive = true
  
}
variable "db_subnet_group_name" {
  type = string
}

variable "vpc_security_group_ids" {
  type = list(string)
}
variable "backend_ip" {
  type = string
}
