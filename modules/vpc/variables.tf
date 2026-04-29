variable "private_subnets" {
  type    = list(string)
  default = ["10.0.3.0/24"] # Adjusted to a single smaller CIDR block
}

resource "aws_vpc" "novapay" {
  cidr_block           = "10.0.0.0/22"  # Reduced CIDR block to save IP space
  enable_dns_hostnames = true
  tags = { Name = "novapay-vpc", Environment = var.environment }
}

# Public Subnets
resource "aws_subnet" "public" {
  count             = 2  # Reduced count to save costs
  vpc_id            = aws_vpc.novapay.id
  cidr_block        = ["10.0.1.0/25", "10.0.1.128/25"][count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = 1  # Reduced count to save costs
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
  count          = 2  # Updated count to match the number of public subnets
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# NAT Gateway for Private Subnets
resource "aws_nat_gateway" "nat" {
  count       = 1  # Reduced to a single NAT Gateway
  allocation_id = aws_eip.nat.id
  subnet_id    = aws_subnet.public[0].id
}

resource "aws_eip" "nat" {
  count = 1  # Only one EIP for the NAT Gateway
  vpc = true
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.novapay.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat.id  # Updated to use NAT Gateway
  }
}

# Associate Private Subnets with Route Table
resource "aws_route_table_association" "private" {
  count          = 1  # Updated count to match the number of private subnets
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Enable VPC Flow Logs with filtering
resource "aws_flow_log" "vpc_flow_logs" {
  log_group_name = "vpc-flow-logs"
  traffic_type   = "ACCEPT"  # Changed to log only accepted traffic
  vpc_id         = aws_vpc.novapay.id
}