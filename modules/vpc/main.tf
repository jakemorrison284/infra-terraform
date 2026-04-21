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

resource "aws_elasticache_cluster" "redis" {
  cluster_id           = "redis-cluster"
  engine              = "redis"
  engine_version      = "Y.Y.Y" # Update to the desired Redis version
  node_type           = "cache.t2.micro" # Update the instance type as needed
  number_cache_nodes   = 3 # Configure cluster size for high availability
  subnet_group_name    = aws_elasticache_subnet_group.redis_subnet_group.name
  security_group_ids   = [aws_security_group.redis_sg.id]

  tags = {
    Name        = "Redis Cluster"
    Environment = var.environment
  }
}

resource "aws_elasticache_subnet_group" "redis_subnet_group" {
  name       = "redis-subnet-group"
  subnet_ids = var.private_subnets

  tags = {
    Name = "Redis Subnet Group"
  }
}