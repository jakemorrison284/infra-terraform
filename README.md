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

### Failure Mode Symptoms and Examples
- **Connectivity Issues in VPC Subnets:**  
  Example: Instances in private subnets are unable to communicate with other subnets or the internet. This could manifest as failed API calls or timeouts.  
  Reference: [AWS VPC Connectivity Troubleshooting](https://docs.aws.amazon.com/vpc/latest/userguide/VPC_Connectivity.html)

- **Incorrect or Missing NAT Gateway Setups:**  
  Example: Private subnet instances fail to access the internet for software updates or external API calls due to missing or misconfigured NAT gateways.  
  Reference: [AWS NAT Gateway Overview](https://docs.aws.amazon.com/vpc/latest/userguide/vpc-nat-gateway.html)

- **Flow Log Configuration Issues:**  
  Example: Unexpected high logging costs or missing flow log data caused by incorrect retention policies or misconfigured flow log resources.  
  Reference: [AWS VPC Flow Logs](https://docs.aws.amazon.com/vpc/latest/userguide/flow-logs.html)

- **Terraform Plan/Apply Failures:**  
  Example: Terraform apply fails with validation errors related to subnet counts, CIDR blocks, or resource conflicts.  
  Reference: [Terraform Error Handling](https://www.terraform.io/language/errors)

### Root Causes
- Unintended changes in CIDR blocks or subnet counts causing IP conflicts or capacity issues.
- Mismatched availability zones and subnet counts leading to uneven distribution or resource creation failures.
- Incorrect conditional logic for NAT gateway creation causing missing or surplus gateways.
- Flow log resource misconfiguration or retention policy errors causing unexpected behavior.

### Mitigation and Rollback Approach
- Immediate rollback to stable commit versions of `main.tf` and `variables.tf` as documented.
- Follow documented rollback procedure including Terraform apply and validation steps.
- Enhanced validation added in `variables.tf` to prevent invalid inputs.
- Close monitoring post-rollback for any residual issues.

### Operational Responsibilities
- **Infrastructure Team:** Responsible for executing rollback script, validating infrastructure state, and monitoring post-rollback.
- **QA Team:** Perform integration and smoke tests on dependent services following rollback.
- **Monitoring Team:** Configure and monitor alerts for connectivity, NAT gateway health, flow logs, and Terraform execution statuses.
- **Incident Response:** Ready to respond to any anomalies detected post-rollback and coordinate with relevant teams.

### Recommendations for Future Changes
- Thorough testing in isolated environments before production deployment.
- Incremental changes with feature toggles to reduce blast radius.
- Clear rollback plan with documented stable commit references.
- Peer reviews focused on critical infrastructure modules.
- Implement automated tests and monitoring alerts for early detection of failure modes.

---

For any questions or issues, please contact the infrastructure team.
