variable "region" {
  description = "The AWS region to create resources in."
  type        = string
  default     = "us-east-1"
}

variable "cidr_vpc" {
  description = "The CIDR block for the VPC."
  type        = string
  default     = "10.0.0.0/16"
}

variable "aws_subnet_CIDR_block" {
  description = "The CIDR block for the subnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "ec2_instance_type" {
  description = "The EC2 instance type."
  type        = string
  default     = "t3.micro"
}

