module "buckets" {
  source        = "../modules/bucket"
  force_destroy = !local.deletion_protection

  for_each = local.buckets

  resource_prefix  = local.resource_prefix
  additional_tags  = local.product_tags
  component_prefix = each.key
}
