output "backend_db_endpoint" {
  description = "RDS endpoint used by backend"
  value       = aws_db_instance.rds.address
}
