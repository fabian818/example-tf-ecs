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

variable "cluster_id" {
  type = string
}

variable "task_definition_arn" {
  type = string
}

variable "target_group_arn" {
  type = string
}

variable "desired_count" {
  type = number
}

variable "min_scale" {
  type = number
}

variable "max_scale" {
  type = number
}

variable "container_name" {
  type = string
}

variable "container_port" {
  type    = string
  default = null
}

variable "security_groups" {
  type = list(string)
}

variable "subnets" {
  type = list(string)
}

variable "capacity_provider_strategy" {
  type = any
}

variable "deletion_protection" {
  type = bool
}
