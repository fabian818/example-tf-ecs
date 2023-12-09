module "docker-lambdas" {
  source   = "../modules/lambda_docker"
  for_each = local.docker_lambdas

  resource_prefix  = local.resource_prefix
  additional_tags  = local.product_tags
  component_prefix = each.key

  security_group_ids = each.value.security_group_ids
  subnet_ids         = each.value.subnet_ids
  image_uri          = each.value.image_uri
  command            = each.value.command

  variables = each.value.variables
}


module "docker-lambdas-scheduling-permissions" {
  source   = "../modules/lambda_event_bridge_permissions"
  for_each = { for k, v in local.docker_lambdas : k => v if v.can_be_scheduled }

  resource_prefix  = local.resource_prefix
  additional_tags  = local.product_tags
  component_prefix = each.key

  function_name = module.docker-lambdas[each.key].function_name
  function_arn  = module.docker-lambdas[each.key].arn
}