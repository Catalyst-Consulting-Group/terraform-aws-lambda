# `scheduled-trigger`

A Terraform module that creates an AWS EventBridge/CloudWatch schedule rule and trigger for an AWS Lambda function.

## Usage

```terraform
module "trigger" {
  source  = "Catalyst-Consulting-Group/lambda/aws//modules/scheduled-trigger"
  version = "~> 1.0"

  function_name       = "foobar-lambda"
  schedule_expression = "cron(0 8 1 * ? *)"
  
  // depends_on is required if provisioning the lambda and the trigger at the same time
  // otherwise Terraform might create the rule before the Lambda is provisioned
  depends_on = [
    module.foobar_lambda,
  ]
}
```
