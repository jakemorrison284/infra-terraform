output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.novapay.id
}

output "public_subnet_ids" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "private_subnet_ids" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "nat_gateway_ids" {
  description = "List of NAT Gateway IDs"
  value       = var.create_nat_gateways ? aws_nat_gateway.nat[*].id : []
}
