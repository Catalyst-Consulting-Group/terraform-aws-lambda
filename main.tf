locals {
  use_image = var.image_uri != null
  use_s3    = var.s3_bucket != null
}

resource "aws_lambda_function" "this" {
  function_name = var.function_name
  description   = var.description

  role = aws_iam_role.this.arn

  runtime       = local.use_image ? null : var.runtime
  architectures = var.architectures

  handler = local.use_image ? null : coalesce(var.handler, "bootstrap")

  package_type = local.use_image ? "Image" : "Zip"
  filename     = (local.use_image || local.use_s3) ? null : "${path.module}/dummy.zip"
  image_uri    = var.image_uri

  dynamic "image_config" {
    for_each = var.image_config == null ? [] : [true]
    content {
      command           = try(var.image_config.command, null)
      entry_point       = try(var.image_config.entry_point, null)
      working_directory = try(var.image_config.working_directory, null)
    }
  }

  s3_bucket         = var.s3_bucket
  s3_key            = var.s3_key
  s3_object_version = var.s3_object_version

  layers = var.layers

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
    aws_iam_role_policy_attachment.basic,
    aws_iam_role_policy_attachment.vpc,
    aws_iam_role_policy_attachment.custom,

    // Depending on the log group will prevent a potential race condition whereby
    // AWS will create it before Terraform does. It's unlikely to happen with the dummy
    // lambda setup, but it doesn't hurt to be careful nevertheless.
    aws_cloudwatch_log_group.this,
  ]

  tags = var.tags

  lifecycle {
    ignore_changes = [
      // These are expected to change outside of Terraform
      filename,
      source_code_hash,
      s3_bucket,
      s3_key,
      s3_object_version,
      image_uri,
    ]
  }
}

// The lambda will automatically use this log group by naming convention
// We manually create it to control the retention period option via Terraform
resource "aws_cloudwatch_log_group" "this" {
  name              = "/aws/lambda/${var.function_name}"
  retention_in_days = var.log_retention_in_days
}
