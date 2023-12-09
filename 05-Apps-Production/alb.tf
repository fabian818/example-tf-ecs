module "albs" {
  source   = "../modules/alb"
  for_each = local.albs

  enable_deletion_protection = local.deletion_protection

  resource_prefix  = local.resource_prefix
  additional_tags  = local.product_tags
  component_prefix = each.key

  security_groups = each.value.security_groups
  subnets         = each.value.subnets
  internal        = each.value.internal
  logs_bucket     = each.value.logs_bucket
  certificate_arn = each.value.certificate_arn

  depends_on = [
    module.vpc
  ]
}

module "app_target_groups" {
  source = "../modules/bg_target_groups"

  for_each = { for k, v in local.ecs_workloads : k => v if v.external_access == true }

  resource_prefix  = local.resource_prefix
  additional_tags  = local.product_tags
  component_prefix = each.key

  vpc_id              = module.vpc.vpc_id
  port                = each.value.ecs.container_port
  health_check_path   = each.value.alb.health_check_path
  health_check_status = each.value.alb.health_check_status
}

module "app_rules" {
  source = "../modules/alb_rule"

  for_each = { for k, v in local.ecs_workloads : k => v if v.external_access == true }

  resource_prefix  = local.resource_prefix
  additional_tags  = local.product_tags
  component_prefix = each.key

  host_headers     = [each.value.host_header]
  listener_arn     = each.value.alb.listener_arn
  target_group_arn = module.app_target_groups[each.key].target_group_blue_arn
}
