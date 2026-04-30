variable "cidr_block" {
  description = "CIDR block for the VPC. Should follow CIDR notation (e.g., 10.0.0.0/22) and not overlap with existing CIDR blocks."
  type        = string
  default     = "10.0.0.0/22"
  validation {
    condition     = can(regex("^([0-9]{1,3}\\.){3}[0-9]{1,3}/[0-9]{1,2}$", var.cidr_block))
    error_message = "The CIDR block format is invalid. Please use CIDR notation (e.g., 10.0.0.0/22)."
  }
}

variable "environment" {
  description = "The environment for the VPC. Must be one of: dev, staging, prod, test."
  type        = string
  default     = "dev"
  validation {
    condition     = contains(["dev", "staging", "prod", "test"], trimspace(var.environment))
    error_message = "The environment must be one of: dev, staging, prod, test."
  }
}
