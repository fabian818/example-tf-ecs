variable "aws_region" {
  type        = string
  description = "AWS Region where infrastructure is deployed"
  default     = "us-east-1"
}

variable "additional_tags" {
  type        = map(string)
  description = "additional tags on resources"
}

variable "resource_prefix" {
  type        = string
  description = "Prefix for resources created in this module"
}

variable "component_prefix" {
  type        = string
  description = "Specific prefix for this component"
}

variable "host_headers" {
  type = list(string)
}

variable "target_group_arn" {
  type = string
}

variable "listener_arn" {
  type = string
}
