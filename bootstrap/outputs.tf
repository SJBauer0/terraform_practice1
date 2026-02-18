# Outputs for the bootstrap module

output "s3_bucket_name" {
  value = aws_s3_bucket.sjb-bucket.id
}

output "mgmt_access_key" {
  value     = aws_iam_access_key.sjb_mgmt.id
  # Marking the access key as sensitive to prevent it from being displayed in logs or output
  sensitive = true
}

output "mgmt_secret_key" {
  value     = aws_iam_access_key.sjb_mgmt.secret
  # Marking the access key as sensitive to prevent it from being displayed in logs or output
  sensitive = true
}