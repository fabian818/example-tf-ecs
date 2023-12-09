# module "waf" {
#   source = "../modules/waf"

#   aws_region       = local.aws_region
#   additional_tags  = local.product_tags
#   resource_prefix  = local.resource_prefix
#   component_prefix = "default-waf"
#   scope            = "REGIONAL"
# }

# module "waf-associations" {
#   source = "../modules/waf-association"

#   for_each = module.albs

#   web_acl_arn      = module.waf.acl_arn
#   web_resource_arn = each.value.arn
# }
