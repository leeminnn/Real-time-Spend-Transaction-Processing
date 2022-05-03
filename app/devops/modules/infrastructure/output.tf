output "vpc_id" {
  value = aws_vpc.itsag1t5_vpc.id
}

output "private_subnets" {
  value = aws_subnet.itsag1t5_private_subnet.*.id
}

output "public_subnets" {
  value = aws_subnet.itsag1t5_public_subnet.*.id
}
