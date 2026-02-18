# Outputs for the bootstrap module

output "s3_bucket_name" {
  value = aws_s3_bucket.sjb-bucket.id
}

output "mgmt_access_key" {
  value     = aws_iam_access_key.sjb_mgmt.id
  sensitive = true
}

output "mgmt_secret_key" {
  value     = aws_iam_access_key.sjb_mgmt.secret
  sensitive = true
}