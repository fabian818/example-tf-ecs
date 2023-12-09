resource "aws_service_discovery_private_dns_namespace" "default" {
  name        = "${local.prefix}-namespace.internal"
  description = "${local.prefix}-namespace"
  vpc         = var.vpc_id
  tags = merge(var.additional_tags, {
    Name = "${local.prefix}-namespace"
  })
}