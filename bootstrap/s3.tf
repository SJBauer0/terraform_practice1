# S3 Bucket for SJB Management
resource "aws_s3_bucket" "sjb-bucket" {
  bucket = var.s3_bucket_name
  tags = {
    Name = "${var.s3_bucket_name}"
  }
}