locals {
  prefix = "${var.resource_prefix}-${var.aws_region}-${var.component_prefix}"
  secret_arns = [
    for secret_key, secret in var.secrets :
    secret.valueFrom
  ]
}
