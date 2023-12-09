module "ecr_repos" {
  source = "../modules/ecr_repo"

  for_each = local.ecr_repos

  force_delete = !local.deletion_protection

  resource_prefix  = local.resource_prefix
  additional_tags  = local.product_tags
  component_prefix = each.key
}
