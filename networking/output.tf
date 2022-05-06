## networking/output.tf
output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "db_subnet_group_name" {
    value = aws_db_subnet_group.subnet_group.*.name
}

output "db_security_group" {
    value = [aws_security_group.public_sg["rds"].id]
}

output "public_sg" {
    value = aws_security_group.public_sg["public"].id
}

output "public_subnets" {
    value = aws_subnet.subnet.*.id
}
