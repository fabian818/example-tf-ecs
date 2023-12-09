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

variable "security_group_ids" {
  type        = list(string)
  description = "Security groups for the ELB"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Subnets groups for the ELB"
}

variable "filename" {
  type = string
}

variable "source_code_hash" {
  type = string
}

variable "handler" {
  type = string
}

variable "runtime" {
  type = string
}

variable "variables" {
  type = any
}
