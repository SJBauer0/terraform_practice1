# IAM Role and User for SJB Management

# Get the IAM policy using the provided ARN
data "aws_iam_policy" "admin_policy" {
  arn = var.policy_arn
}

# Create an IAM user for SJB management
resource "aws_iam_user" "sjb_mgmt" {
  name = var.username-mgmt

  tags = {
    tag-key = var.username-mgmt
  }
}

# Create an access key for the SJB management user
resource "aws_iam_access_key" "sjb_mgmt" {
  user = aws_iam_user.sjb_mgmt.name
}

# Attach the admin policy to the SJB management user
resource "aws_iam_user_policy" "admin_policy" {
  name   = var.admin-policy-name
  user   = aws_iam_user.sjb_mgmt.name
  policy = data.aws_iam_policy.admin_policy.policy
}
