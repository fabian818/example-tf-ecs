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

variable "image_url" {
  type = string
}

variable "command" {
  type = list(string)
}

variable "cpu" {
  type = number
}

variable "memory" {
  type = number
}

variable "container_port" {
  type = number
}

variable "secrets" {
  type = list(any)
}

variable "environment_variables" {
  type = list(any)
}

variable "mount_points" {
  type = any
}

variable "file_system_id" {
  type = string
}

variable "volume_directory" {
  type = string
}

variable "volume_name" {
  type = string
}