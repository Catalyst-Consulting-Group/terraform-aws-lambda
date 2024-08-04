resource "aws_iam_role" "this" {
  name               = var.function_name
  assume_role_policy = data.aws_iam_policy_document.this.json

  tags = var.iam_role_tags
}

data "aws_iam_policy_document" "this" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

// Basic
data "aws_iam_policy" "basic" {
  name = "AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "basic" {
  role       = aws_iam_role.this.name
  policy_arn = data.aws_iam_policy.basic.arn
}

moved {
  from = aws_iam_role_policy_attachment.basic_execution_role_policy_attachment
  to   = aws_iam_role_policy_attachment.basic
}

// VPC
data "aws_iam_policy" "vpc" {
  count = var.vpc_config == null ? 0 : 1
  name  = "AWSLambdaENIManagementAccess"
}

resource "aws_iam_role_policy_attachment" "vpc" {
  count      = var.vpc_config == null ? 0 : 1
  role       = aws_iam_role.this.name
  policy_arn = data.aws_iam_policy.vpc[0].arn
}

// Custom policy attachments
resource "aws_iam_role_policy_attachment" "custom" {
  count = length(var.policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = var.policy_arns[count.index]
}

moved {
  from = aws_iam_role_policy_attachment.extra_role_policy_attachment
  to   = aws_iam_role_policy_attachment.custom
}
