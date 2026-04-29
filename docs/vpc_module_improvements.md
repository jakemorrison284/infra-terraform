# VPC Module Variable Contracts and Best Practices

## Overview
This document outlines the suggested improvements for variable contracts and best practices for the VPC module within the `infra-terraform` repository.

## Suggested Improvements

### 1. `private_subnets`
- **Type**: `list(string)`  
- **Current Default**: `['10.0.3.0/24']`  
- **Improvements**:  
  - **Validation**: Add a check to ensure that CIDR blocks do not overlap with existing CIDR blocks in use.

### 2. `public_subnets_count`
- **Type**: `number`  
- **Current Default**: `2`  
- **Validation**: Must be between 1 and 5.  
- **Improvements**:  
  - **Contextual Documentation**: Enhance the error message to explain why the limit exists (e.g., cloud provider limits).

### 3. `private_subnets_count`
- **Type**: `number`  
- **Current Default**: `1`  
- **Validation**: Must be greater than 0.  
- **Improvements**:  
  - **Maximum Limit**: Specify a maximum limit to avoid excessive resource creation based on architectural needs.

### 4. `vpc_cidr_block`
- **Type**: `string`  
- **Current Default**: `10.0.0.0/22`  
- **Validation**: Validates CIDR format using regex.  
- **Improvements**:  
  - **Overlapping CIDR Check**: Implement a validation to ensure that the CIDR block does not overlap with existing VPCs or other networks in use.

### General Recommendations
- **Detailed Documentation**: Enhance variable descriptions to include constraints and implications of variable values.
- **Dynamic Defaults**: Consider using dynamic values for defaults based on the environment or existing configurations.
- **Additional Validations**: Implement additional contextual validations for counts, such as minimum subnet size based on the number of hosts required.

## Conclusion
Implementing these suggested improvements will enhance the robustness and usability of the VPC module, making it more resilient to common configuration issues.