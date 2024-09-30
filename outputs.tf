output "function_name" {
  value = aws_lambda_function.this.function_name
}

output "arn" {
  value = aws_lambda_function.this.arn
}

output "role" {
  value = aws_iam_role.this.name
}

output "role_arn" {
  value = aws_iam_role.this.arn
}

output "invoke_arn" {
  value = aws_lambda_function.this.invoke_arn
}

output "log_group_name" {
  value = aws_cloudwatch_log_group.this.name
}
