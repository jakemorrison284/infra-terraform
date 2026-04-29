resource "aws_instance" "nat" {
  ami           = "ami-0c55b159cbfafe01e" // Ensure this is a valid NAT instance AMI
  instance_type = "t3a.micro" // Updated instance type for better performance
  subnet_id     = aws_subnet.public[0].id
  associate_public_ip_address = true

  tags = {
    Name = "NAT Instance"
  }
}

resource "aws_subnet" "public" {
  count             = 2 // Reduced count to save resources
  vpc_id            = aws_vpc.novapay.id
  cidr_block        = ["10.0.1.0/25", "10.0.1.128/25"][count.index]
  availability_zone = var.availability_zones[count.index]
  map_public_ip_on_launch = true
}

resource "aws_flow_log" "vpc_flow_logs" {
  log_group_name = "vpc-flow-logs"
  traffic_type   = "ACCEPT" // Changed to log only accepted traffic
  vpc_id         = aws_vpc.novapay.id
}