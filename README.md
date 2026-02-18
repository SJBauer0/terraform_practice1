
# Terraform Practice Project

## Overview
This project demonstrates Terraform infrastructure as code practices, including bootstrap infrastructure setup and EC2 instance deployment on AWS.

## Project Structure
```
terraform_practice1/
├── bootstrap/          # Bootstrap infrastructure (IAM user, S3 bucket)
├── infra/              # EC2 instances and related resources
└── run.sh              # Deployment script
```

## Prerequisites
- Terraform installed
- AWS account with appropriate credentials
- Bash shell

## Deployment

Run the deployment script to initialize and apply both bootstrap and infrastructure configurations:

```bash
./run.sh
```

### What the script does:
1. Initializes and deploys bootstrap infrastructure
2. Exports AWS credentials from bootstrap outputs
3. Configures remote state backend using S3
4. Deploys EC2 instances with exported credentials

## Backend Configuration
The project uses S3 for remote state management. The bucket is created during bootstrap and referenced in the infrastructure deployment.

## Cleanup
To destroy all resources:
```bash
terraform -chdir=./infra destroy
terraform -chdir=./bootstrap destroy
```
