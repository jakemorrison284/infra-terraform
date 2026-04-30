resource "aws_vpc" "novapay" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = true
  tags = {
    Name        = "novapay-vpc"
    Environment = var.environment
    Module      = "VPC"
    Owner       = var.owner
  }
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

# NAT Gateways and NAT Instances

# Elastic IPs for NAT Gateways
resource "aws_eip" "nat" {
  count = var.nat_strategy == "gateway" ? var.nat_gateway_count : 0
  vpc   = true
  tags = {
    Name        = "novapay-nat-eip-${count.index}"
    Environment = var.environment
    Module      = "VPC"
    Owner       = var.owner
  }
}

# NAT Gateways
resource "aws_nat_gateway" "nat" {
  count         = var.nat_strategy == "gateway" ? var.nat_gateway_count : 0
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id
  tags = {
    Name        = "novapay-nat-gw-${count.index}"
    Environment = var.environment
    Module      = "VPC"
    Owner       = var.owner
  }
}

# NAT Instances Security Group
resource "aws_security_group" "nat_instance_sg" {
  count       = var.nat_strategy == "instance" ? var.nat_gateway_count : 0
  name        = "novapay-nat-instance-sg-${count.index}"
  description = "Security group for NAT instances"
  vpc_id      = aws_vpc.novapay.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "novapay-nat-instance-sg-${count.index}"
    Environment = var.environment
    Module      = "VPC"
    Owner       = var.owner
  }
}

# NAT Instances
resource "aws_instance" "nat_instance" {
  count             = var.nat_strategy == "instance" ? var.nat_gateway_count : 0
  ami               = var.nat_instance_ami
  instance_type     = var.nat_instance_type
  subnet_id         = aws_subnet.public[count.index].id
  source_dest_check = false
  security_groups   = [aws_security_group.nat_instance_sg[count.index].name]

  tags = {
    Name        = "novapay-nat-instance-${count.index}"
    Environment = var.environment
    Module      = "VPC"
    Owner       = var.owner
  }
}

# Elastic IPs for NAT Instances
resource "aws_eip" "nat_instance_eip" {
  count = var.nat_strategy == "instance" ? var.nat_gateway_count : 0
  instance = aws_instance.nat_instance[count.index].id
  vpc      = true
  tags = {
    Name        = "novapay-nat-instance-eip-${count.index}"
    Environment = var.environment
    Module      = "VPC"
    Owner       = var.owner
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
  }

  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = var.nat_strategy == "gateway" ? aws_nat_gateway.nat[count.index % var.nat_gateway_count].id : null
    network_interface_id = var.nat_strategy == "instance" ? aws_instance.nat_instance[count.index % var.nat_gateway_count].primary_network_interface_id : null
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
  log_group_name = var.flow_log_group_name
  traffic_type   = var.flow_log_traffic_type
  vpc_id         = aws_vpc.novapay.id
  tags = {
    Name        = "novapay-flow-logs"
    Environment = var.environment
    Module      = "VPC"
    Owner       = var.owner
  }
}
