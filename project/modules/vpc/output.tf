output "vpc_id" {
  value = aws_vpc.myvpc.id
}
output "db_subnet_group_name" {
  value = aws_db_subnet_group.subgroup.name
}
output "sg_id" {
  value = aws_security_group.sg.id
}
output "public_subnet_ids" {
  value = [aws_subnet.public1.id, aws_subnet.public2.id]
}

output "private_subnet_ids" {
  value = [
    aws_subnet.private1.id,
    aws_subnet.private2.id,
    aws_subnet.private3.id,
    aws_subnet.private4.id,
    aws_subnet.private5.id,
    aws_subnet.private6.id
  ]
}
#frontend_ami="ami-0ff4c8fb495a5a50d"
#backend_ami="ami-0ff4c8fb495a5a50d"
#vpc_security_group_ids = ["sg-0d089a479271d1422"]
#backend_private_subnets=["subnet-0d8a177650b3fb767","subnet-0e5bd9e00bda275c5","subnet-0caf4d5c852ba8b6c","subnet-056b29ead0603af56","subnet-07ec1e4c57f8eac94","subnet-0b751a2e1033491a5"]
#frontend_public_subnets=["subnet-04fe1f31c9dcf44b3","subnet-03ea9d15847438044"]
