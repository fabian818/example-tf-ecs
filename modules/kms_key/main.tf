resource "aws_kms_key" "default" {
  description = "${local.prefix}-kms-key"

  tags = merge(var.additional_tags, {
    Name = "${local.prefix}-kms-key"
  })
}