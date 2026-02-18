# Deploy the bootstrap infrastructure
terraform -chdir=./bootstrap init
terraform -chdir=./bootstrap apply -auto-approve

# Export AWS credentials from Terraform outputs
export AWS_ACCESS_KEY_ID=$(terraform -chdir=../bootstrap output -raw mgmt_access_key)
export AWS_SECRET_ACCESS_KEY=$(terraform -chdir=../bootstrap output -raw mgmt_secret_key)
export AWS_S3_BUCKET=$(terraform -chdir=../bootstrap output -raw s3_bucket_name)

# Deploy EC2 Instances using the exported credentials
terraform -chdir=./infra init --backend-config="bucket=$AWS_S3_BUCKET" -backend-config="key=infra/terraform.tfstate" -backend-config="region=us-east-1"
terraform -chdir=./infra apply -auto-approve

