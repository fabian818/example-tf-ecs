module "efs" {
  source = "../modules/efs"

  for_each = local.efs_instances

  resource_prefix  = local.resource_prefix
  additional_tags  = local.product_tags
  component_prefix = each.key

  subnet_id       = each.value.subnet_id
  security_groups = each.value.security_groups
}