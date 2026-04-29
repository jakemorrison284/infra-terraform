variable "private_subnets" {
  type        = list(string)
  description = "List of CIDR blocks for private subnets"
  default     = ["10.0.3.0/24"] 
}

variable "public_subnets_count" {
  description = "Number of public subnets (must be between 1 and 5)"
  type        = number
  default     = 2
  validation {
    condition     = (var.public_subnets_count >= 1 && var.public_subnets_count <= 5)
    error_message = "The number of public subnets must be between 1 and 5."
  }
}

variable "private_subnets_count" {
  description = "Number of private subnets"
  type        = number
  default     = 1
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC (should follow CIDR notation)"
  type        = string
  default     = "10.0.0.0/22"
}