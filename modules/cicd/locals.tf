locals {
  prefix       = "${var.resource_prefix}-${var.aws_region}-${var.component_prefix}"
  small_prefix = "${var.resource_prefix}-${var.component_prefix}"
}
