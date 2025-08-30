output "db_endpoint" {
  value = aws_db_instance.rds.address
}

output "db_username" {
  value = local.db_secret["username"]
}

output "db_password" {
  value     = local.db_secret["password"]
  sensitive = true
}

output "db_name" {
  value = var.db_name
}
