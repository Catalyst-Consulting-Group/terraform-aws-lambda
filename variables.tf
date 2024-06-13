variable "function_name" {
  description = "(Required) Unique name for your Lambda Function"
  type        = string
  nullable    = false
}

variable "description" {
  description = "(Optional) Description of what your Lambda Function does"
  type        = string
  nullable    = true
  default     = null
}

variable "runtime" {
  description = "(Required) Identifier of the function's runtime"
  type        = string
  nullable    = false
}

variable "handler" {
  description = "(Optional, Default: 'bootstrap') Function entrypoint in your code"
  type        = string
  nullable    = false
  default     = "bootstrap"
}

variable "layers" {
  description = "(Optional, Default: []) List of Lambda Layer Version ARNs (maximum of 5) to attach to your Lambda Function"
  type        = list(string)
  nullable    = false
  default     = []
}

variable "memory_size" {
  description = "(Optional, Default: 128) Amount of memory in MB your Lambda Function can use at runtime"
  type        = number
  nullable    = false
  default     = 128
}

variable "timeout" {
  description = "(Optional, Default: 3) Amount of time your Lambda Function has to run in seconds"
  type        = number
  nullable    = false
  default     = 3
}

variable "environment" {
  description = "(Optional, Default: {}) A map of environment variables"
  type        = map(string)
  nullable    = false
  default     = {}
}

variable "vpc_config" {
  description = "(Optional, Default: null) An object containing subnet and security group IDs for running in a VPC"
  type = object({
    subnet_ids         = list(string)
    security_group_ids = list(string)
  })
  nullable = true
  default  = null
}

variable "policy_arns" {
  description = "(Optional, Default: []) A list of policy ARNs to attach to the lambda execution role"
  type        = list(string)
  nullable    = false
  default     = []
}

variable "log_retention_in_days" {
  description = "(Optional, Default: 3) Specifies the number of days you want to retain log events"
  type        = number
  nullable    = false
  default     = 3
}
