module "codebuild" {
  source   = "../modules/codebuild"
  for_each = local.codebuild

  resource_prefix  = local.resource_prefix
  additional_tags  = local.product_tags
  component_prefix = each.key

  buildspec_content = each.value.buildspec_content
  image             = each.value.image
}

module "codepipeline" {
  source   = "../modules/codepipeline"
  for_each = local.pipelines

  resource_prefix  = local.resource_prefix
  additional_tags  = local.product_tags
  component_prefix = each.key

  stages               = each.value.stages
  artifacts_bucket_arn = each.value.artifacts_bucket_arn

}