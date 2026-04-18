# infra-terraform

NovaPay infrastructure-as-code (AWS).

## Modules
- `vpc/` — VPC, subnets, security groups
- `eks/` — Kubernetes cluster
- `rds/` — PostgreSQL
- `elasticache/` — Redis for idempotency

## Getting Started

To get started with this project, clone the repository and navigate to the appropriate module. Make sure you have the necessary tools installed (Terraform, AWS CLI).

## Prerequisites
- Terraform 1.0 or higher
- AWS account with appropriate permissions

## Usage

Run the following commands to deploy the infrastructure:

1. Initialize Terraform: `terraform init`
2. Plan the deployment: `terraform plan`
3. Apply the changes: `terraform apply`

## Cleanup

To destroy the infrastructure, run: `terraform destroy`

## Contributing

1. Fork the repository.
2. Create a new branch (`git checkout -b feature-branch`).
3. Make your changes.
4. Push to the branch (`git push origin feature-branch`).
5. Create a new Pull Request.

## License

This project is licensed under the MIT License.