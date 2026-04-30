resource "aws_vpc" "novapay" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name        = "novapay-vpc"
    Environment = var.environment
    Module      = "VPC"
    Owner       = var.owner
    CostCenter  = var.cost_center
    Project     = var.project
  }
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = var.public_subnets_count
  vpc_id                  = aws_vpc.novapay.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.public_availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name        = "novapay-public-subnet-${count.index}"
    Environment = var.environment
    Module      = "VPC"
    Tier        = "Public"
    Owner       = var.owner
    CostCenter  = var.cost_center
    Project     = var.project
  }
}

# Private Subnets
resource "aws_subnet" "private" {
  count             = var.private_subnets_count
  vpc_id            = aws_vpc.novapay.id
  cidr_block        = var.private_subnets[count.index]
  availability_zone = var.private_availability_zones[count.index]
  tags = {
    Name        = "novapay-private-subnet-${count.index}"
    Environment = var.environment
    Module      = "VPC"
    Tier        = "Private"
    Owner       = var.owner
    CostCenter  = var.cost_center
    Project     = var.project
  }
}

# Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.novapay.id
  tags = {
    Name        = "novapay-igw"
    Environment = var.environment
    Module      = "VPC"
    Owner       = var.owner
    CostCenter  = var.cost_center
    Project     = var.project
  }
}

# Route Table for Public Subnets
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.novapay.id
  tags = {
    Name        = "novapay-public-rt"
    Environment = var.environment
    Module      = "VPC"
    Tier        = "Public"
    Owner       = var.owner
    CostCenter  = var.cost_center
    Project     = var.project
  }

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

# NAT Gateway for Private Subnets (conditional creation and count)
resource "aws_nat_gateway" "nat" {
  count         = var.create_nat_gateways ? var.nat_gateway_count : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    Name        = "novapay-nat-gw-${count.index}"
    Environment = var.environment
    Module      = "VPC"
    Owner       = var.owner
    CostCenter  = var.cost_center
    Project     = var.project
  }
}

resource "aws_eip" "nat" {
  count = var.create_nat_gateways ? var.nat_gateway_count : 0
  vpc   = true
  tags = {
    Name        = "novapay-nat-eip-${count.index}"
    Environment = var.environment
    Module      = "VPC"
    Owner       = var.owner
    CostCenter  = var.cost_center
    Project     = var.project
  }
}

# Route Table for Private Subnets
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.novapay.id
  tags = {
    Name        = "novapay-private-rt"
    Environment = var.environment
    Module      = "VPC"
    Tier        = "Private"
    Owner       = var.owner
    CostCenter  = var.cost_center
    Project     = var.project
  }

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = var.create_nat_gateways ? aws_nat_gateway.nat[count.index % var.nat_gateway_count].id : null
  }
}

# Associate Private Subnets with Route Table
resource "aws_route_table_association" "private" {
  count          = var.private_subnets_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# CloudWatch Log Group for Flow Logs with retention
resource "aws_cloudwatch_log_group" "flow_logs" {
  name              = var.flow_log_group_name
  retention_in_days = var.flow_log_retention_days
  tags = {
    Name        = "novapay-flow-logs"
    Environment = var.environment
    Module      = "VPC"
    Owner       = var.owner
    CostCenter  = var.cost_center
    Project     = var.project
  }
}

# Enable or disable VPC Flow Logs based on variable
resource "aws_flow_log" "vpc_flow_logs" {
  count          = var.enable_flow_logs ? 1 : 0
  log_group_name = aws_cloudwatch_log_group.flow_logs.name
  traffic_type   = var.flow_log_traffic_type
  vpc_id         = aws_vpc.novapay.id
  tags = {
    Name        = "novapay-flow-logs"
    Environment = var.environment
    Module      = "VPC"
    Owner       = var.owner
    CostCenter  = var.cost_center
    Project     = var.project
  }
}

