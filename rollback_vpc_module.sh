#!/bin/bash

# Rollback script for VPC module enhancements in infra-terraform repository

# Stable commit SHAs to revert to
MAIN_TF_SHA="b3566cec4bbeb8cdf3912762c51330c51f3f7f73"
VARIABLES_TF_SHA="0f5fb3e924968c1f4d513b4bf6d50abd436ed60e"
MERGE_PR_SHA="560e7b54d2453d320a3d101bc162f83de3328bbe"

# Function to rollback a file to a specific commit SHA
rollback_file() {
  local file_path="$1"
  local commit_sha="$2"
  echo "Rolling back $file_path to commit $commit_sha"
  git checkout $commit_sha -- $file_path
  if [ $? -ne 0 ]; then
    echo "Failed to rollback $file_path to $commit_sha"
    exit 1
  fi
}

# Step 1: Rollback main.tf and variables.tf
rollback_file "modules/vpc/main.tf" $MAIN_TF_SHA
rollback_file "modules/vpc/variables.tf" $VARIABLES_TF_SHA

# Step 2: Initialize Terraform
echo "Initializing Terraform..."
terraform init
if [ $? -ne 0 ]; then
  echo "Terraform init failed"
  exit 1
fi

# Step 3: Plan Terraform changes
echo "Planning Terraform changes..."
terraform plan
if [ $? -ne 0 ]; then
  echo "Terraform plan failed"
  exit 1
fi

# Step 4: Apply Terraform changes
echo "Applying Terraform changes..."
terraform apply -auto-approve
if [ $? -ne 0 ]; then
  echo "Terraform apply failed"
  exit 1
fi

# Step 5: Verification (manual steps recommended)
echo "Rollback applied successfully. Please verify infrastructure state manually:"
echo "- Confirm Terraform plan outputs match expected stable state"
echo "- Check AWS console for VPC, subnets, route tables, NAT gateways"
echo "- Run integration and smoke tests on dependent services"
echo "- Monitor logs and alerts for anomalies post-rollback"

exit 0
