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

variable "vpc_id" {
  type        = string
  description = "Security groups for the ELB"
}

variable "health_check_path" {
  type        = string
  description = "Security groups for the ELB"
}

variable "health_check_port" {
  type = string
}

variable "health_check_status" {
  type        = number
  description = "Status for the HC"
}

variable "port" {
  type        = number
  description = "Port for the Target group"
}

variable "instance_id" {
  type = string
}

variable "health_check_enabled" {
  type = bool
}
