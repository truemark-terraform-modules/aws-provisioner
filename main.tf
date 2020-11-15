data "aws_caller_identity" "current" {}

locals {
  s3_bucket = var.s3_bucket == null ? "${data.aws_caller_identity.current.account_id}-terraform" : var.s3_bucket
}

resource "aws_iam_user" "provisioner" {
  name = var.name
}

# This policy grants the provisioner user access to specific paths in the S3 bucket holding terraform state.
# This is needed to prevent different provisioner users from stepping on one another's changes. Additionally,
# there is sensitive information stored in the state files in these S3 buckets which should be restricted.
resource "aws_iam_policy" "s3_provisioner" {
  name = "${var.name}-s3-terraform"
  path = var.path
  description = "Allows access to ${local.s3_bucket}/${var.s3_prefix}"
  policy = <<EOF
{
 "Version":"2012-10-17",
 "Statement": [
    {
      "Sid": "AllowBucketList",
      "Effect": "Allow",
      "Action": ["s3:ListAllMyBuckets", "s3:GetBucketLocation"],
      "Resource": ["arn:aws:s3:::*"]
    },
    {
      "Sid": "AllowListBucket",
      "Effect": "Allow",
      "Action": ["s3:ListBucket"],
      "Resource": ["arn:aws:s3:::${local.s3_bucket}"]
    },
    {
      "Sid": "AllowPath",
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject", "s3:ListObjects"],
      "Resource": "arn:aws:s3:::${local.s3_bucket}/${var.s3_prefix}/*"
    },
    {
      "Sid": "AllowWorkspacePath",
      "Effect": "Allow",
      "Action": ["s3:GetObject", "s3:PutObject", "s3:ListObjects"],
      "Resource": "arn:aws:s3:::${local.s3_bucket}/env:/*/${var.s3_prefix}/*"
    },
    {
      "Sid": "AllowDynamo",
      "Effect": "Allow",
      "Action": ["dynamodb:PutItem", "dynamodb:GetItem", "dynamodb:DeleteItem"],
      "Resource": "arn:aws:dynamodb:*:${data.aws_caller_identity.current.account_id}:table/${local.s3_bucket}"
    }
  ]
}
EOF
}

resource "aws_iam_user_policy_attachment" "s3_provisioner" {
  policy_arn = aws_iam_policy.s3_provisioner.arn
  user = aws_iam_user.provisioner.name
}

resource "aws_iam_policy" "provisioner" {
  count = var.policy == null ? 0 : 1
  name = var.name
  path = var.path
  description = "Access policy for IAM user ${var.name}"
  policy = var.policy
}

resource "aws_iam_user_policy_attachment" "provisioner" {
  count = var.policy == null ? 0 : 1
  policy_arn = aws_iam_policy.provisioner[count.index].arn
  user = aws_iam_user.provisioner.name
}

resource "aws_iam_user_policy_attachment" "attachments" {
  count = length(var.policy_arns)
  policy_arn = var.policy_arns[count.index]
  user = aws_iam_user.provisioner.name
}
