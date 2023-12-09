locals {
  prefix              = "${var.resource_prefix}-${var.aws_region}-${var.component_prefix}"
  timestamp           = timestamp()
  timestamp_sanitized = replace("${local.timestamp}", "/[- TZ:]/", "")
}
