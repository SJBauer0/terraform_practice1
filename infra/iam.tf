
# IAM Role for SSM to manage SJB instances
resource "aws_iam_role" "sjb_ssm_role" {
  name = "sjb_ssm_role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ssm.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

