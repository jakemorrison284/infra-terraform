variable "private_subnets" {
  type        = list(string)
  description = "List of CIDR blocks for private subnets"
  default     = ["10.0.3.0/24", "10.0.4.0/24"] 
  validation {
    condition     = alltrue([for cidr in var.private_subnets : cidrnet(cidr) in cidrnet(var.vpc_cidr_block)])
    error_message = "All private subnet CIDR blocks must be within the VPC CIDR block."
  }
}

variable "public_subnets" {
  type        = list(string)
  description = "List of CIDR blocks for public subnets"
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
  validation {
    condition     = length(var.public_subnets) == var.public_subnets_count && alltrue([for cidr in var.public_subnets : cidrnet(cidr) in cidrnet(var.vpc_cidr_block)])
    error_message = "The length of public_subnets list must match public_subnets_count and all CIDR blocks must be within the VPC CIDR block."
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

variable "availability_zones" {
  description = "List of availability zones for subnets. Example: [\"us-east-1a\", \"us-east-1b\"]"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
  validation {
    condition     = length(var.availability_zones) == var.public_subnets_count || length(var.availability_zones) == var.private_subnets_count || length(var.availability_zones) == 0
    error_message = "The number of availability zones must match either public_subnets_count or private_subnets_count, or be empty."
  }
}

variable "enable_flow_logs" {
  description = "Enable or disable VPC Flow Logs"
  type        = bool
  default     = true
}

variable "flow_log_group_name" {
  description = "The name of the CloudWatch Log Group for VPC Flow Logs"
  type        = string
  default     = "/aws/vpc/flow-logs"
}

variable "flow_log_traffic_type" {
  description = "The type of traffic to log (ACCEPT, REJECT, ALL)"
  type        = string
  default     = "ALL"
  validation {
    condition     = contains(["ACCEPT", "REJECT", "ALL"], var.flow_log_traffic_type)
    error_message = "flow_log_traffic_type must be one of: ACCEPT, REJECT, ALL"
  }
}

variable "nat_gateway_count" {
  description = "Number of NAT Gateways to create. To reduce costs, keep this as low as possible (default 1)."
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

variable "cost_center" {
  description = "Cost center tag for resource allocation and billing"
  type        = string
  default     = "default-cost-center"
}

variable "project" {
  description = "Project tag for resource organization"
  type        = string
  default     = "default-project"
}
