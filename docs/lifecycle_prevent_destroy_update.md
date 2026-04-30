# Important Update: Lifecycle prevent_destroy Added to Critical VPC Resources

## Overview

To enhance the safety and stability of our infrastructure, a new lifecycle rule `prevent_destroy = true` has been added to critical resources within the VPC module. This change is intended to prevent accidental deletion of key networking components, which could cause significant outages or disruptions.

## Affected Resources

The following resources now have the `prevent_destroy` lifecycle rule applied:

- VPC (`aws_vpc.novapay`)
- Public and Private Subnets (`aws_subnet.public`, `aws_subnet.private`)
- Internet Gateway (`aws_internet_gateway.igw`)
- Route Tables for Public and Private subnets (`aws_route_table.public`, `aws_route_table.private`)
- NAT Gateways and associated Elastic IPs (`aws_nat_gateway.nat`, `aws_eip.nat`)

## Implications

- **Accidental Deletions Prevented:** Terraform will block destroy operations on these resources unless the lifecycle rule is removed.
- **Intentional Changes Require Care:** Any legitimate need to delete or replace these resources will require manual changes to the Terraform configuration or a planned process to safely remove the lifecycle block.
- **Operational Considerations:** Teams should review their change management procedures to accommodate this protection and ensure that infrastructure updates can be applied smoothly.
- **Rollback and Recovery:** Ensure rollback scripts and recovery plans are up to date to handle scenarios where manual intervention is necessary.

## Recommendations

- Review and communicate this change with your teams.
- Plan infrastructure changes that might affect these resources carefully.
- Test Terraform plans and applies in a staging environment before production.
- Consult documentation or infrastructure owners if unsure about how to proceed with changes affecting these resources.

For questions or assistance, please contact the infrastructure team.
