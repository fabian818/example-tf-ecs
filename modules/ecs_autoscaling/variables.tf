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

variable "cluster_name" {
  type        = string
  description = "Specific prefix for this component"
}


variable "service_name" {
  type        = string
  description = "Specific prefix for this component"
}


variable "target_memory" {
  type        = string
  description = "Specific prefix for this component"
}


variable "target_cpu" {
  type        = string
  description = "Specific prefix for this component"
}



variable "max_capacity" {
  type        = string
  description = "Specific prefix for this component"
}


variable "min_capacity" {
  type        = string
  description = "Specific prefix for this component"
}
