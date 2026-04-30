# Updated VPC Configuration

resource "aws_vpc" "novapay" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = { Name = "novapay-vpc", Environment = var.environment, Module = "VPC" }
}

# Public Subnets
resource "aws_subnet" "public" {
  count             = var.public_subnets_count
  vpc_id            = aws_vpc.novapay.id
  cidr_block        = var.public_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = var.private_subnets_count
  vpc_id            = aws_vpc.novapay.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.availability_zones[count.index]
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.novapay.id
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.novapay.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
}

# Associate Public Subnets with Route Table
resource "aws_route_table_association" "public" {
  count          = var.public_subnets_count
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# NAT Gateway for Private Subnets
resource "aws_nat_gateway" "nat" {
  count       = length(var.availability_zones)
  allocation_id = aws_eip.nat[count.index].id
  subnet_id    = aws_subnet.public[count.index].id
}

resource "aws_eip" "nat" {
  count = length(var.availability_zones)
  vpc = true
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.novapay.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id
  }
}

# Associate Private Subnets with Route Table
resource "aws_route_table_association" "private" {
  count          = var.private_subnets_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Enable VPC Flow Logs with filtering
resource "aws_flow_log" "vpc_flow_logs" {
  log_group_name = "vpc-flow-logs"
  traffic_type   = "ACCEPT"
  vpc_id         = aws_vpc.novapay.id
}
