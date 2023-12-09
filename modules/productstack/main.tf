resource "aws_security_group" "productstack_components" {
  for_each = var.components

  name        = "${local.prefix}-${each.key}-sg"
  description = "${local.prefix}-${each.key}-sg"
  vpc_id      = var.vpc_id
  tags = merge(var.additional_tags, {
    Name = "${local.prefix}-${each.key}-sg"
  })
}
