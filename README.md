# Lambda Terraform Module

A Terraform module that creates a minimalistic, opinionated AWS Lambda function, IAM role, and CloudWatch log group.

It currently does not support the wide range of options and features that Lambdas have to offer,
opting instead for a simpler model that is useful to Catalyst Consulting Group.

By default, this module uses a dummy zip file to provision the Lambda.
It is expected that external processes (ex. CI/CD) will deploy and publish new versions.

You can also use `image_uri` to select an image from ECR or `s3_bucket` and `s3_key` to select a zip file from S3 instead.
See the [`aws_lambda_function` docs](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/lambda_function) for more information.

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
