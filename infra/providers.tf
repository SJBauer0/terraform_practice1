# Terraform configuration for AWS infrastructure
terraform {
  backend "s3" {
    
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      # This version constraint allows for any 6.x version of the AWS provider, but not 7.0 or higher.
      version = "~> 6.0"
    }
  }
}

provider "aws" {
    region = var.region
}
