resource "aws_lambda_function" "this" {
  function_name = var.function_name
  description   = var.description
  runtime       = var.runtime
  handler       = var.handler
  role          = aws_iam_role.this.arn
  filename      = "${path.module}/dummy.zip"
  package_type  = "Zip"

  memory_size = var.memory_size
  timeout     = var.timeout

  dynamic "environment" {
    for_each = length(var.environment) == 0 ? [] : [true]
    content {
      variables = var.environment
    }
  }

  dynamic "vpc_config" {
    for_each = var.vpc_config == null ? [] : [true]
    content {
      subnet_ids         = var.vpc_config.subnet_ids
      security_group_ids = var.vpc_config.security_group_ids
    }
  }

  depends_on = [
    aws_iam_role.this,
    aws_iam_role_policy_attachment.basic_execution_role_policy_attachment,
    aws_iam_role_policy_attachment.extra_role_policy_attachment,

    // Depending on the log group will prevent a potential race condition whereby
    // AWS will create it before Terraform does. It's unlikely to happen with the dummy
    // lambda setup, but it doesn't hurt to be careful nevertheless.
    aws_cloudwatch_log_group.this,
  ]
}

resource "aws_iam_role" "this" {
  name               = var.function_name
  assume_role_policy = data.aws_iam_policy_document.this.json
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

data "aws_iam_policy" "basic_execution_role" {
  name = "AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "basic_execution_role_policy_attachment" {
  role       = aws_iam_role.this.name
  policy_arn = data.aws_iam_policy.basic_execution_role.arn
}

resource "aws_iam_role_policy_attachment" "extra_role_policy_attachment" {
  count = length(var.policy_arns)

  role       = aws_iam_role.this.name
  policy_arn = var.policy_arns[count.index]
}

// The lambda will automatically use this log group by naming convention
// We manually create it to control the retention period option via Terraform
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_in_days
}
