variable "aws_region" {
  default = "us-east-1"
}

variable "component_prefix" {
  type        = string
  description = "Specific prefix for this component"
}

variable "additional_tags" {
  type        = map(string)
  description = "additional tags on resources"
}

variable "resource_prefix" {
  type        = string
  description = "Prefix for resources created in this module"
}

variable "vpc_id" {
  type        = string
  description = "ID of the VPC to deploy productstack into"
}

variable "components" {
  description = "Map of storage security groupss"
  type = map(object({
    name    = string
    ingress = any
    egress  = any
  }))
}
