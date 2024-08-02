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
  description = "(Conditional) Identifier of the function's runtime. Required unless image_uri is specified."
  type        = string
  nullable    = true
  default     = null
}

variable "architectures" {
  description = "(Optional, Default: [\"x86_64\"]) The list of architectures supported by the function"
  type        = list(string)
  nullable    = false
  default     = ["x86_64"]
}

variable "handler" {
  description = "(Conditional) Function entrypoint in your code. Required unless image_uri is specified."
  type        = string
  nullable    = true
  default     = null
}

variable "image_uri" {
  description = "(Optional, Default: null) The URI of a container image in ECR. Conflicts with s3_bucket."
  type        = string
  nullable    = true
  default     = null
}

variable "image_config" {
  description = "(Optional, Default: null) Container image configuration values that override the values in the container image Dockerfile"
  type = object({
    command           = optional(list(string))
    entry_point       = optional(list(string))
    working_directory = optional(string)
  })
  nullable = true
  default  = null
}

variable "s3_bucket" {
  description = "(Optional, Default: null) The S3 bucket holding the function's deployment package. Conflicts with image_uri."
  type        = string
  nullable    = true
  default     = null
}

variable "s3_key" {
  description = "(Optional, Default: null) The S3 key of an object in the deployment bucket"
  type        = string
  nullable    = true
  default     = null
}

variable "s3_object_version" {
  description = "(Optional, Default: null) The object version of the deployment package"
  type        = string
  nullable    = true
  default     = null
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
