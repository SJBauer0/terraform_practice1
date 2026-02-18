data "aws_iam_policy" "admin_policy" {
  arn = var.policy_arn
}

resource "aws_iam_user" "sjb_mgmt" {
  name = var.username-mgmt

  tags = {
    tag-key = var.username-mgmt
  }
}

resource "aws_iam_access_key" "sjb_mgmt" {
  user = aws_iam_user.sjb_mgmt.name
}

resource "aws_iam_user_policy" "admin_policy" {
  name   = var.admin-policy-name
  user   = aws_iam_user.sjb_mgmt.name
  policy = data.aws_iam_policy.admin_policy.policy
}
