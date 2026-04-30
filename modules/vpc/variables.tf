variable "private_subnets" {
  type        = list(string)
  description = "List of CIDR blocks for private subnets"
  default     = ["10.0.3.0/24"] 
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
  description = "CIDR block for the VPC (should follow CIDR notation and not overlap with existing CIDR blocks)"
  type        = string
  default     = "10.0.0.0/22"
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.vpc_cidr_block))
    error_message = "The CIDR block format is invalid. Please use CIDR notation (e.g., 10.0.0.0/22) and ensure it does not overlap with existing CIDR blocks."
  }
}

variable "nat_gateway_count" {
  description = "Number of NAT gateways to create (for cost savings, can be less than or equal to availability zones)"
  type        = number
  default     = 1
  validation {
    condition     = var.nat_gateway_count >= 1
    error_message = "nat_gateway_count must be at least 1."
  }
}

variable "enable_flow_logs" {
  description = "Enable or disable VPC flow logs"
  type        = bool
  default     = true
}

variable "flow_log_group_name" {
  description = "CloudWatch log group name for VPC flow logs"
  type        = string
  default     = "novapay-vpc-flow-logs"
}

variable "flow_log_traffic_type" {
  description = "Traffic type to log (ACCEPT, REJECT, ALL)"
  type        = string
  default     = "ALL"
  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.flow_log_traffic_type)
    error_message = "flow_log_traffic_type must be one of ACCEPT, REJECT, or ALL."
  }
}
