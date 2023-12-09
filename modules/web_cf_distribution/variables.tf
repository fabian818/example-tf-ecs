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

variable "aliases" {
  type        = list(string)
  description = "List of DNS aliases"
}

variable "domain_name" {
  type        = string
  description = "domain name to redirect traffic"
}

variable "logs_bucket" {
  type        = string
  description = "Bucket name to save distribution logs"
}

variable "certificate_arn" {
  type        = string
  description = "Certificate ARN for the Distribution"
}

variable "origin_id" {
  type        = string
  description = "Identifier for the origin"
}
