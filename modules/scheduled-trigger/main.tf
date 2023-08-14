data "aws_lambda_function" "lambda" {
  function_name = var.function_name
}

resource "aws_cloudwatch_event_rule" "this" {
  name                = var.function_name
  schedule_expression = var.schedule_expression
  is_enabled          = var.is_enabled
}

resource "aws_cloudwatch_event_target" "this" {
  rule = aws_cloudwatch_event_rule.this.name
  arn  = data.aws_lambda_function.lambda.arn
}

resource "aws_lambda_permission" "this" {
  action        = "lambda:InvokeFunction"
  function_name = var.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.this.arn
}
