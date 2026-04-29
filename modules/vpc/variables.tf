variable "private_subnets" {
  type    = list(string)
  default = ["10.0.3.0/24"] # Adjusted to a single smaller CIDR block
}

variable "public_subnets_count" {
  description = "Number of public subnets"
  type        = number
  default     = 2  # Reduced count to save costs
}

variable "private_subnets_count" {
  description = "Number of private subnets"
  type        = number
  default     = 1  # Reduced count to save costs
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/22"  # Adjusted CIDR block for efficiency
}
