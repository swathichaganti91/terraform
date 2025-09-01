######## outputs.tf ########

# Frontend instance public info
output "frontend_public_ip" {
  description = "Public IP of the frontend EC2"
  value       = aws_instance.frontend.public_ip
}

output "frontend_public_dns" {
  description = "Public DNS of the frontend EC2"
  value       = aws_instance.frontend.public_dns
}

# Backend instance info
output "backend_private_ip" {
  description = "Private IP of the backend EC2"
  value       = aws_instance.backend.private_ip
}

output "backend_public_ip" {
  description = "Public IP of the backend EC2 (if needed for SSH/debug)"
  value       = aws_instance.backend.public_ip
}

# Backend DB details (optional, already from RDS module)
output "backend_db_endpoint" {
  description = "RDS endpoint used by backend"
  value       = module.rds.db_endpoint
}

output "backend_db_name" {
  description = "Database name"
  value       = module.rds.db_name
}
