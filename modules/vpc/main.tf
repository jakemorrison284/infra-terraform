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

resource "aws_vpc_ipv4_cidr_block_association" "secondary" {
  count      = length(var.secondary_cidr_blocks)
  vpc_id     = aws_vpc.novapay.id
  cidr_block = var.secondary_cidr_blocks[count.index]
}

# Public Subnets
resource "aws_subnet" "public" {
  count                   = var.public_subnets_count
  vpc_id                  = aws_vpc.novapay.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = var.availability_zones[count.index]
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
  availability_zone = var.availability_zones[count.index]
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

# NAT Gateway for Private Subnets (reduced count and conditional creation)
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

# Route Table for Private Subnets (updated to use mod to map NAT Gateway index, conditional NAT Gateway)
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
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = var.create_nat_gateways ? aws_nat_gateway.nat[count.index % var.nat_gateway_count].id : null
  }
}

# Associate Private Subnets with Route Table
resource "aws_route_table_association" "private" {
  count          = var.private_subnets_count
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
}

# Enable or disable VPC Flow Logs based on variable
resource "aws_flow_log" "vpc_flow_logs" {
  count          = var.enable_flow_logs ? 1 : 0
  log_group_name = var.flow_log_group_name
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

resource "aws_security_group" "private_sg" {
  name        = "novapay-private-sg"
  description = "Security group for private subnet instances"
  vpc_id      = aws_vpc.novapay.id

  ingress {
    description = "Allow SSH from allowed CIDRs"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allow_ssh_cidr_blocks
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "novapay-private-sg"
    Environment = var.environment
    Module      = "VPC"
    Owner       = var.owner
    CostCenter  = var.cost_center
    Project     = var.project
  }
}
