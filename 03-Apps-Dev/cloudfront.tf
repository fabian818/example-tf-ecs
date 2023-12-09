module "s3_cloudfront" {
  source = "../modules/cf_distribution"

  for_each = local.cloudfront

  resource_prefix  = local.resource_prefix
  additional_tags  = local.product_tags
  component_prefix = each.key

  aliases            = each.value.aliases
  certificate_arn    = each.value.certificate_arn
  bucket_arn         = each.value.bucket_arn
  bucket_domain_name = each.value.bucket_domain_name
  cache_policy_id    = each.value.cache_policy_id
}