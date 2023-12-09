module "buckets" {
  source = "../modules/bucket"

  for_each = local.s3_buckets

  force_destroy = !local.deletion_protection

  resource_prefix  = local.resource_prefix
  additional_tags  = local.product_tags
  component_prefix = each.key
}
