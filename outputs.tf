# outputs.tf updates

# Ensure outputs are relevant and well documented
output "vpc_id" {
  value = aws_vpc.my_vpc.id
  description = "The ID of the VPC created."
}

output "private_subnets" {
  value = aws_subnet.private.*.id
  description = "List of private subnet IDs."
}

# Additional relevant outputs can be defined here.
