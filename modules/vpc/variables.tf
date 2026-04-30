variable "private_subnets" {
  type        = list(string)
  description = "List of CIDR blocks for private subnets"
  default     = ["10.0.3.0/24", "10.0.4.0/24"] 
}

variable "public_subnets" {
  type        = list(string)
  description = "List of CIDR blocks for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  validation {
    condition     = length(var.public_subnets) == var.public_subnets_count
    error_message = "The length of public_subnets list must match public_subnets_count."
  }
}

variable "public_subnets_count" {
  description = "Number of public subnets (must be between 1 and 5)"
  type        = number
  default     = 2
  validation {
    condition     = (var.public_subnets_count >= 1 && var.public_subnets_count <= 5)
    error_message = "The number of public subnets must be between 1 and 5. Please specify a valid count."
  }
}

variable "private_subnets_count" {
  description = "Number of private subnets (must be greater than 0)"
  type        = number
  default     = 2
  validation {
    condition     = (var.private_subnets_count > 0)
    error_message = "The number of private subnets must be greater than 0. Please specify a count of at least 1."
  }
}

variable "vpc_cidr_block" {
  description = "CIDR block for the VPC (should follow CIDR notation and not overlap with existing CIDR blocks). Choose size based on IP needs, e.g., /24 for small, /22 for medium, /16 for large environments."
  type        = string
  default     = "10.0.0.0/22"
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.vpc_cidr_block))
    error_message = "The CIDR block format is invalid. Please use CIDR notation (e.g., 10.0.0.0/22) and ensure it does not overlap with existing CIDR blocks."
  }
}

variable "enable_flow_logs" {
  description = "Enable or disable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways to create. To reduce costs, keep this as low as possible (default 1). Should not exceed public_subnets_count."
  type        = number
  default     = 1
  validation {
    condition     = var.nat_gateway_count > 0 && var.nat_gateway_count <= var.public_subnets_count
    error_message = "nat_gateway_count must be greater than 0 and less than or equal to public_subnets_count"
  }
}

variable "create_nat_gateways" {
  description = "Whether to create NAT Gateways"
  type        = bool
  default     = true
}

variable "nat_gateway_mapping" {
  description = "Optional list to explicitly map NAT Gateways to private subnets to optimize costs. Length should match private_subnets_count. Use index of NAT Gateway for each private subnet."
  type        = list(number)
  default     = []
  validation {
    condition     = length(var.nat_gateway_mapping) == 0 || length(var.nat_gateway_mapping) == var.private_subnets_count
    error_message = "nat_gateway_mapping length must be zero or equal to private_subnets_count."
  }
}
