output "vpc_id" {
  value = aws_vpc.myvpc.id
}
output "db_subnet_group_name" {
  value = aws_db_subnet_group.subgroup.name
}
output "sg_id" {
  value       = aws_security_group.sg.id
}
output "public_subnet_ids" {
  description = "Public Subnet ID"
  value       = [aws_subnet.public1.id, aws_subnet.public2.id]
}
output "private_subnet_ids" {
  description = "Private Subnet ID"
  value = [aws_subnet.private1.id, aws_subnet.private2.id, aws_subnet.private3.id, aws_subnet.private4.id, aws_subnet.private5.id, aws_subnet.private6.id]
  
}
