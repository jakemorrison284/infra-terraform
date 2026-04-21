# Redis Configuration and Backup Plan

## Redis Configuration

Redis is utilized in the `elasticache/` module for idempotency within the NovaPay infrastructure on AWS. Below is the finalized configuration for Redis:

### Instance Type
- **Type:** `cache.t2.micro` (adjust based on expected load)

### Parameters
- **Redis Version:** **Y.Y.Y** (update to the latest version)
- **Persistence:** Enabled (RDB snapshotting)
- **Snapshotting Frequency:** Every 12 hours
- **Backup Retention Period:** 7 days

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
- **Number of Retained Backups:** 5 snapshots

### Manual Snapshots
- **Frequency:** As needed, especially before major deployments or changes.

### Monitoring and Alerts
- Set up CloudWatch alarms for:
  - Memory usage exceeding 75%
  - CPU utilization exceeding 80%
  - Evictions exceeding a threshold (e.g., 100 per hour)

## Conclusion

This document serves as an essential reference for the Redis configuration and backup strategies employed in the NovaPay infrastructure. Regular reviews and updates should be conducted to ensure optimal performance and reliability.