# Redis Deployment Configuration

## Overview
This document outlines the configuration and deployment procedures for the Redis cluster utilized in our infrastructure. The recent upgrade aims to enhance performance, security, and compatibility with the latest Redis features.

## Redis Configuration

### Version
- Upgraded Redis version from **X.X.X** to **Y.Y.Y**.

### Configuration Changes
- Updated the Redis version references in configuration files.
- Modified the cluster configuration to optimize performance and ensure redundancy.
- Adjusted parameters in the **main.tf** file for improved resource allocation and scaling.
- Documentation in the README has been updated to reflect the new Redis version and its features.

### Backup Strategies
- Regular backups should be scheduled to ensure data safety.
- Utilize Redis persistence options (RDB and AOF) for data recovery.

## Deployment Steps
1. Clone the repository:
   ```bash
   git clone https://github.com/jakemorrison284/infra-terraform.git
   cd infra-terraform
   ```
2. Switch to the branch with the Redis configuration:
   ```bash
   git checkout feature/redis-cluster-upgrade
   ```
3. Apply the Terraform configuration:
   ```bash
   terraform init
   terraform apply
   ```

## Rollback Procedures
In the event of any critical issues during or after the upgrade, the following rollback procedures should be followed:

1. **Revert Configuration Changes**: Restore the configuration changes in the **main.tf** file to the previous version (X.X.X).
2. **Redeploy Infrastructure**: Execute the Terraform commands to redeploy the infrastructure with the previous Redis version:
   ```bash
   terraform apply
   ```
3. **Restore Data**: If any data migration changes impact the structure or format, utilize the backups taken prior to the upgrade to restore any affected data.
4. **Immediate Action**: Rollback will be initiated immediately if any major issues are detected during the upgrade process or post-deployment testing.

### Testing
- All changes will be validated in a staging environment before merging to ensure functionality and performance.
- Automated tests will be run to verify that all existing features continue to work as expected.