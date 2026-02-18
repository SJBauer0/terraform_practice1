variable "s3_bucket_name" {
  description = "Bucket Name"
  type        = string
  default     = "sjb-s3-bucket-12341234"
}

variable "username-mgmt" {
  description = "Username for management"
  type = string
  default = "sjb-admin"
}

variable "admin-policy-name" {
  description = "Admin Policy Name"
  type = string
  default = "admin-policy"
}

variable "policy_arn" {
  description = "ARN of the Admin Policy"
  type = string
  default = "admin_policy_arn"
}