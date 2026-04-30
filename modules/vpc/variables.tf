variable "private_subnets" {
  type        = list(string)
  description = "List of CIDR blocks for private subnets within the VPC. CIDRs must be within the VPC CIDR block and should not overlap each other."
  validation {
    condition = alltrue([for cidr in var.private_subnets : can(cidrhost(cidr, 0)) && cidrsubnet(cidr, 0, 0) == cidrsubnet(var.vpc_cidr_block, 0, 0)]) &&
      length(var.private_subnets) == length(distinct(var.private_subnets))
    error_message = "All private subnet CIDR blocks must be within the VPC CIDR block and must not overlap each other."
  }
}

variable "public_subnets" {
  type        = list(string)
  description = "List of CIDR blocks for public subnets within the VPC. CIDRs must be within the VPC CIDR block and should not overlap each other."
  validation {
    condition = length(var.public_subnets) == var.public_subnets_count && alltrue([for cidr in var.public_subnets : can(cidrhost(cidr, 0)) && cidrsubnet(cidr, 0, 0) == cidrsubnet(var.vpc_cidr_block, 0, 0)]) &&
      length(var.public_subnets) == length(distinct(var.public_subnets))
    error_message = "The length of public_subnets list must match public_subnets_count and all CIDR blocks must be within the VPC CIDR block without overlap."
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
  description = "Number of private subnets (must be between 1 and 10)"
  type        = number
  default     = 2
  validation {
    condition = (var.private_subnets_count >= 1 && var.private_subnets_count <= 10) && var.private_subnets_count == length(var.private_subnets)
    error_message = "The number of private subnets must be between 1 and 10 and match the length of the private_subnets list."
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

variable "public_availability_zones" {
  description = "List of availability zones for public subnets. Must be valid AWS availability zones (e.g., us-east-1a, us-east-1b)."
  type        = list(string)
  validation {
    condition     = length(var.public_availability_zones) == var.public_subnets_count && alltrue([for az in var.public_availability_zones : can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}[a-z]$", az))])
    error_message = "The number of public availability zones must match public_subnets_count and all must be valid AWS availability zones (e.g., us-east-1a, us-east-1b)."
  }
}

variable "private_availability_zones" {
  description = "List of availability zones for private subnets. Must be valid AWS availability zones (e.g., us-east-1a, us-east-1b)."
  type        = list(string)
  validation {
    condition     = length(var.private_availability_zones) == var.private_subnets_count && alltrue([for az in var.private_availability_zones : can(regex("^[a-z]{2}-[a-z]+-[0-9]{1}[a-z]$", az))])
    error_message = "The number of private availability zones must match private_subnets_count and all must be valid AWS availability zones (e.g., us-east-1a, us-east-1b)."
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
  validation {
    condition     = length(trimspace(var.flow_log_group_name)) > 0
    error_message = "flow_log_group_name cannot be empty"
  }
}

variable "flow_log_retention_days" {
  description = "Retention period for CloudWatch Log Group in days"
  type        = number
  default     = 30
}

variable "flow_log_traffic_type" {
  description = "The type of traffic to log (ACCEPT, REJECT, ALL)"
  type        = string
  default     = "ACCEPT"
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
    condition     = var.nat_gateway_count > 0 && var.nat_gateway_count <= var.public_subnets_count && var.nat_gateway_count <= 3
    error_message = "nat_gateway_count must be greater than 0, less than or equal to public_subnets_count, and no more than 3."
  }
}

variable "create_nat_gateways" {
  description = "Whether to create NAT Gateways"
  type        = bool
  default     = true
}

variable "cost_center" {
  description = "Cost center tag for resource allocation and billing. Should be a non-empty string identifying the billing code or department. Allowed characters are letters, numbers, hyphens, and underscores."
  type        = string
  default     = "default-cost-center"
  validation {
    condition     = length(trimspace(var.cost_center)) > 0 && can(regex("^[a-zA-Z0-9-_]+$", var.cost_center))
    error_message = "cost_center cannot be empty and must only contain letters, numbers, hyphens, and underscores."
  }
}

variable "project" {
  description = "Project tag for resource organization. Should be a non-empty string representing the project name or identifier. Allowed characters are letters, numbers, hyphens, and underscores."
  type        = string
  default     = "default-project"
  validation {
    condition     = length(trimspace(var.project)) > 0 && can(regex("^[a-zA-Z0-9-_]+$", var.project))
    error_message = "project cannot be empty and must only contain letters, numbers, hyphens, and underscores."
  }
}

variable "region" {
  description = "AWS region for resource deployment. Should be a valid AWS region string (e.g., us-east-1)."
  type        = string
  default     = "us-east-1"
  validation {
    condition     = length(trimspace(var.region)) > 0
    error_message = "region cannot be empty"
  }
}

variable "environment" {
  description = "Environment tag for resource organization. Should be a non-empty string indicating the deployment environment (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
  validation {
    condition     = length(trimspace(var.environment)) > 0
    error_message = "environment cannot be empty"
  }
}

variable "owner" {
  description = "Owner tag for resource management. Should be a non-empty string indicating the responsible person or team."
  type        = string
  default     = "unknown"
  validation {
    condition     = length(trimspace(var.owner)) > 0
    error_message = "owner cannot be empty"
  }
}

variable "public_ip_on_launch" {
  description = "Whether to assign public IPs on launch for public subnets"
  type        = bool
  default     = true
}
