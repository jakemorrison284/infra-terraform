# Redis Configuration and Backup Plan

## Redis Configuration

Redis is utilized in the `elasticache/` module for idempotency within the NovaPay infrastructure on AWS. Below is the finalized configuration for Redis:

### Instance Type
- **Type:** `cache.t2.micro` (adjust based on expected load)

### Parameters
- **Redis Version:** **Y.Y.Y** (update to the latest version)
- **Persistence:** Enabled (RDB snapshotting)
- **Snapshotting Frequency:** Every 12 hours
- **Backup Retention Period:** 14 days  

### Security Configuration
- **VPC:** Integrated within the existing VPC configuration to ensure network isolation.
- **Security Groups:** Allow inbound traffic from application servers on the Redis port (default is 6379).

## New Features Introduced in Redis Upgrade
- Enhanced performance and security features from the latest Redis version.
- Compatibility with new Redis features for optimal resource allocation and scaling.

## Backup Strategies

To ensure data durability and recovery for Redis, the following backup strategies are implemented:

### Automated Backups
- **Enabled:** Yes
- **Backup Window:** Between 02:00 and 03:00 UTC daily
- **Number of Retained Backups:** 10 snapshots

### Manual Snapshots
- **Frequency:** As needed, especially before major deployments or changes. Document the procedure for taking and restoring manual snapshots.

### Testing Recovery Procedures
- **Frequency:** Conduct recovery testing quarterly to ensure that backup restoration processes meet defined RTO and RPO objectives.

### Monitoring and Alerts
- Set up CloudWatch alarms for:
  - Memory usage exceeding 75%
  - CPU utilization exceeding 80%
  - Evictions exceeding a threshold (e.g., 100 per hour)
  - Backup success/failure notifications.

## Conclusion

This document serves as an essential reference for the Redis configuration and backup strategies employed in the NovaPay infrastructure. Regular reviews and updates should be conducted to ensure optimal performance and reliability.

---

## Rollback Documentation for VPC Module Enhancements

This section documents the rollback procedure for recent enhancements made to the VPC module in the infra-terraform repository.

### Rollback Commit SHAs and Description
- `b3566cec4bbeb8cdf3912762c51330c51f3f7f73`: Rollback VPC module main.tf to previous stable state
- `0f5fb3e924968c1f4d513b4bf6d50abd436ed60e`: Rollback VPC module variables.tf to previous stable state
- `560e7b54d2453d320a3d101bc162f83de3328bbe`: Merge pull request for rollback of VPC module enhancements

### Stable State Reference
The stable state of the VPC module is represented by the above commit SHAs. Rolling back to these commits ensures the infrastructure returns to a known stable configuration.

### Rollback Procedure
1. Checkout the stable commit or rollback branch:
   ```bash
   git checkout b3566cec4bbeb8cdf3912762c51330c51f3f7f73
   git checkout 0f5fb3e924968c1f4d513b4bf6d50abd436ed60e
   ```
2. Apply the Terraform configuration:
   ```bash
   terraform init
   terraform plan
   terraform apply
   ```
3. Verify infrastructure is restored to the stable state.

### Validation Steps
- Confirm all Terraform plan outputs match expected stable infrastructure.
- Check AWS console for expected VPC, subnets, route tables, and NAT gateways.
- Run integration and smoke tests on dependent services.
- Monitor logs and alerts for any anomalies post-rollback.

---

## Rollback Failure Mode for VPC Module Enhancements

### Description
The recent enhancements to the VPC module introduced changes to subnet configurations, routing, NAT gateways, and flow logs. These changes were rolled back due to issues identified during rollback review, which necessitated returning to the previous stable state.

### Failure Mode Symptoms
- Potential misconfigurations causing connectivity issues in VPC subnets.
- Incorrect or missing NAT gateway setups leading to failed outbound internet access for private subnets.
- Flow log configurations causing unexpected logging behavior or costs.
- Terraform plan/apply failures due to variable validation errors or resource conflicts.

### Root Causes
- Unintended changes in CIDR blocks or subnet counts.
- Mismatched availability zones and subnet counts.
- Incorrect conditional logic for NAT gateway creation.
- Flow log resource misconfiguration or retention policy errors.

### Mitigation and Rollback Approach
- Immediate rollback to the stable commit versions of main.tf and variables.tf.
- Follow documented rollback procedure including Terraform apply and validation steps.
- Enhanced validation added in variables.tf to prevent invalid inputs.
- Close monitoring post-rollback for any residual issues.

### Recommendations for Future Changes
- Thorough testing in isolated environments.
- Incremental changes with feature toggles.
- Clear rollback plan with documented stable commit references.
- Peer reviews focused on critical infrastructure modules.

---

For any questions or issues, please contact the infrastructure team.
