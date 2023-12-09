resource "aws_ssm_parameter" "default" {
  name  = "${local.prefix}-param"
  type  = var.type
  value = var.value

  lifecycle {
    ignore_changes = [
      value
    ]
  }
}
