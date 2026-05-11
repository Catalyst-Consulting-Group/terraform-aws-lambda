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

  memory_size                    = var.memory_size
  timeout                        = var.timeout
  reserved_concurrent_executions = var.reserved_concurrent_executions

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

// Allowed Triggers

resource "aws_lambda_permission" "current_version_triggers" {
  for_each = { for k, v in var.allowed_triggers : k => v if var.create_current_version_allowed_triggers }

  region = var.region

  function_name = aws_lambda_function.this.function_name
  qualifier     = aws_lambda_function.this.version

  statement_id_prefix    = try(each.value.statement_id, each.key)
  action                 = try(each.value.action, "lambda:InvokeFunction")
  principal              = try(each.value.principal, format("%s.amazonaws.com", try(each.value.service, "")))
  principal_org_id       = try(each.value.principal_org_id, null)
  source_arn             = try(each.value.source_arn, null)
  source_account         = try(each.value.source_account, null)
  event_source_token     = try(each.value.event_source_token, null)
  function_url_auth_type = try(each.value.function_url_auth_type, null)

  lifecycle {
    create_before_destroy = true
  }
}

# Error: Error adding new Lambda Permission for lambda: InvalidParameterValueException: We currently do not support adding policies for $LATEST.
resource "aws_lambda_permission" "unqualified_alias_triggers" {
  for_each = { for k, v in var.allowed_triggers : k => v if var.create_unqualified_alias_allowed_triggers }

  region = var.region

  function_name = aws_lambda_function.this.function_name

  statement_id_prefix    = try(each.value.statement_id, each.key)
  action                 = try(each.value.action, "lambda:InvokeFunction")
  principal              = try(each.value.principal, format("%s.amazonaws.com", try(each.value.service, "")))
  principal_org_id       = try(each.value.principal_org_id, null)
  source_arn             = try(each.value.source_arn, null)
  source_account         = try(each.value.source_account, null)
  event_source_token     = try(each.value.event_source_token, null)
  function_url_auth_type = try(each.value.function_url_auth_type, null)

  lifecycle {
    create_before_destroy = true
  }
}

// Event Source Mapping
resource "aws_lambda_event_source_mapping" "this" {
  for_each = var.event_source_mapping

  region = var.region

  function_name = aws_lambda_function.this.arn

  event_source_arn = try(each.value.event_source_arn, null)

  batch_size                         = try(each.value.batch_size, null)
  maximum_batching_window_in_seconds = try(each.value.maximum_batching_window_in_seconds, null)
  enabled                            = try(each.value.enabled, true)
  starting_position                  = try(each.value.starting_position, null)
  starting_position_timestamp        = try(each.value.starting_position_timestamp, null)
  parallelization_factor             = try(each.value.parallelization_factor, null)
  maximum_retry_attempts             = try(each.value.maximum_retry_attempts, null)
  maximum_record_age_in_seconds      = try(each.value.maximum_record_age_in_seconds, null)
  bisect_batch_on_function_error     = try(each.value.bisect_batch_on_function_error, null)
  topics                             = try(each.value.topics, null)
  queues                             = try(each.value.queues, null)
  function_response_types            = try(each.value.function_response_types, null)
  tumbling_window_in_seconds         = try(each.value.tumbling_window_in_seconds, null)

  dynamic "destination_config" {
    for_each = try(each.value.destination_arn_on_failure, null) != null ? [true] : []
    content {
      on_failure {
        destination_arn = each.value["destination_arn_on_failure"]
      }
    }
  }

  dynamic "scaling_config" {
    for_each = try([each.value.scaling_config], [])
    content {
      maximum_concurrency = try(scaling_config.value.maximum_concurrency, null)
    }
  }


  dynamic "self_managed_event_source" {
    for_each = try(each.value.self_managed_event_source, [])
    content {
      endpoints = self_managed_event_source.value.endpoints
    }
  }

  dynamic "self_managed_kafka_event_source_config" {
    for_each = try(each.value.self_managed_kafka_event_source_config, [])
    content {
      consumer_group_id = self_managed_kafka_event_source_config.value.consumer_group_id
    }
  }
  dynamic "amazon_managed_kafka_event_source_config" {
    for_each = try(each.value.amazon_managed_kafka_event_source_config, [])
    content {
      consumer_group_id = amazon_managed_kafka_event_source_config.value.consumer_group_id
    }
  }

  dynamic "source_access_configuration" {
    for_each = try(each.value.source_access_configuration, [])
    content {
      type = source_access_configuration.value["type"]
      uri  = source_access_configuration.value["uri"]
    }
  }

  dynamic "filter_criteria" {
    for_each = try(each.value.filter_criteria, null) != null ? [true] : []

    content {
      dynamic "filter" {
        for_each = try(flatten([each.value.filter_criteria]), [])

        content {
          pattern = try(filter.value.pattern, null)
        }
      }
    }
  }

  dynamic "document_db_event_source_config" {
    for_each = try(each.value.document_db_event_source_config, [])

    content {
      database_name   = document_db_event_source_config.value.database_name
      collection_name = try(document_db_event_source_config.value.collection_name, null)
      full_document   = try(document_db_event_source_config.value.full_document, null)
    }
  }

  dynamic "metrics_config" {
    for_each = try([each.value.metrics_config], [])

    content {
      metrics = metrics_config.value.metrics
    }
  }

  dynamic "provisioned_poller_config" {
    for_each = try([each.value.provisioned_poller_config], [])
    content {
      maximum_pollers = try(provisioned_poller_config.value.maximum_pollers, null)
      minimum_pollers = try(provisioned_poller_config.value.minimum_pollers, null)
    }
  }

  tags = merge(var.tags, try(each.value.tags, {}))
}
