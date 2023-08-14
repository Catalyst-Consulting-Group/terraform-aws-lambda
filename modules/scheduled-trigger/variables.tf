variable "function_name" {
  description = "(Required) The name of the lambda function"
  type        = string
  nullable    = false
}

variable "schedule_expression" {
  description = "(Required) The scheduling expression. For example, cron(0 20 * * ? *) or rate(5 minutes)"
  type        = string
  nullable    = false
}

variable "is_enabled" {
  description = "(Optional, Default: true) Whether the rule should be enabled"
  type        = bool
  nullable    = false
  default     = true
}
