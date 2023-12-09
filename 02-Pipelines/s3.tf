module "artifacts-bucket" {
  source = "../modules/bucket"

  force_destroy = !local.deletion_protection

  resource_prefix  = local.resource_prefix
  additional_tags  = local.product_tags
  component_prefix = "artifacts"
}
