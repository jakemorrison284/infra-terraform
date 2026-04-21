# Updated VPC Configuration

resource "aws_vpc" "novapay" {
  cidr_block           = "10.0.0.0/20"  # Adjusted CIDR block for future growth
  enable_dns_hostnames = true
  tags = { Name = "novapay-vpc", Environment = var.environment }
}

# Public Subnets
resource "aws_subnet" "public" {
  count             = 3  # Increased count for additional public subnet
  vpc_id            = aws_vpc.novapay.id
  cidr_block        = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"][count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = 4  # Increased count for additional private subnets
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
  count          = 3  # Updated count to match the number of public subnets
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# NAT Gateway for Private Subnets
resource "aws_nat_gateway" "nat" {
  count       = length(var.availability_zones)  # Create a NAT Gateway for each AZ
  allocation_id = aws_eip.nat[count.index].id
  subnet_id    = aws_subnet.public[count.index].id
}

resource "aws_eip" "nat" {
  count = length(var.availability_zones)  # Create an EIP for each NAT Gateway
  vpc = true
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.novapay.id

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat[count.index].id  # Updated to use NAT Gateway
  }
}

# Associate Private Subnets with Route Table
resource "aws_route_table_association" "private" {
  count          = 4  # Updated count to match the number of private subnets
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Enable VPC Flow Logs with filtering
resource "aws_flow_log" "vpc_flow_logs" {
  log_group_name = "vpc-flow-logs"
  traffic_type   = "ACCEPT"  # Changed to log only accepted traffic
  vpc_id         = aws_vpc.novapay.id
}