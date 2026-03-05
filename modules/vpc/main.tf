resource "aws_vpc" "novapay" {
  cidr_block           = var.cidr_block
  enable_dns_hostnames = true
  tags = { Name = "novapay-vpc", Environment = var.environment }
}

resource "aws_subnet" "private" {
  count             = length(var.private_subnets)
  vpc_id            = aws_vpc.novapay.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
}
