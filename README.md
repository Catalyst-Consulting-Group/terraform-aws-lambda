# Lambda Terraform Module

A Terraform module that creates a minimalistic, opinionated AWS Lambda function.

It currently does not support the wide range of options and features that Lambdas have to offer,
opting instead for a simple model that is useful to Catalyst Consulting Group.

It uses a dummy zip file to provision the Lambda.
It is expected that external processes (ex. CI/CD) will deploy and publish new versions.

## Usage

```terraform
module "foobar_lambda" {
  source  = "Catalyst-Consulting-Group/lambda/aws"
  version = "~> 1.0"

  function_name = "foobar-lambda"
  runtime       = "provided.al2"
  
  description = "Foobars the bucket"

  environment = {
    BUCKET_NAME = "foobar-bucket"
  }

  policy_arns = [
    aws_iam_policy.foobar_bucket_ro.arn,
  ]
}
```

## Authors

This module is maintained by [Catalyst Consulting Group, Inc](https://github.com/Catalyst-Consulting-Group).

## License

MIT License. See [LICENSE](./LICENSE) for full details.

## Submodules

- [`scheduled-trigger`](./modules/scheduled-trigger/README.md)
