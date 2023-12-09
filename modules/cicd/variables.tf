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

variable "github_token_name" {
  type = string
}

variable "owner" {
  type = string
}

variable "repository_branch" {
  type = string
}

variable "github_repository_name" {
  type = string
}

variable "artifacts_bucket" {
  type = string
}

variable "artifacts_bucket_arn" {
  type = string
}

variable "docker_repository_url" {
  type = string
}

variable "task_definition" {
  type = string
}

variable "task_definition_arn" {
  type = string
}

variable "deployments" {
  type = any
}

variable "execution_role_arn" {
  type = string
}

variable "task_role_arn" {
  type = string
}

variable "buildspec_content" {
  type = string
}

variable "build_env_vars" {
  type = list(any)
}

variable "parameter_name" {
  type = string
}

variable "parameter_buildspec_content" {
  type = string
}

variable "migration_env_vars" {
  type = list(any)
}

variable "migration_buildspec_content" {
  type = string
}
