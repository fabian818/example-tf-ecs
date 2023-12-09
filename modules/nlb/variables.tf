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

variable "security_groups" {
  type        = list(string)
  description = "Security groups for the ELB"
}

variable "vpc_id" {
  type        = string
  description = "VPC for the ELB"
}

variable "subnets" {
  type        = list(string)
  description = "Subnets groups for the ELB"
}

variable "internal" {
  type        = bool
  description = "Boolean flag to set if the ELB is internal or not"
}

variable "logs_bucket" {
  type = string
}

variable "certificate_arn" {
  type = string
}


variable "enable_deletion_protection" {
  type = bool
}

variable "ports" {
  type = any
}

variable "instance_id" {
  type = string
}
