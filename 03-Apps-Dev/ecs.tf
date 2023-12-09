module "ecs_cluster" {
  source = "../modules/ecs_cluster"

  resource_prefix  = local.resource_prefix
  additional_tags  = local.product_tags
  component_prefix = "default"
}

module "ecs_task_definitions" {
  source = "../modules/ecs_task_definition"

  for_each = local.ecs_workloads

  resource_prefix  = local.resource_prefix
  additional_tags  = local.product_tags
  component_prefix = each.key

  image_url             = each.value.ecs.image_url
  cpu                   = each.value.ecs.cpu
  memory                = each.value.ecs.memory
  secrets               = each.value.ecs.secrets
  container_port        = each.value.ecs.container_port
  environment_variables = each.value.ecs.environment_variables
  command               = each.value.ecs.command
  mount_points          = each.value.ecs.mount_points
  file_system_id        = each.value.ecs.file_system_id
  volume_directory      = each.value.ecs.volume_directory
  volume_name           = each.value.ecs.volume_name

  depends_on = [
    module.ecs_cluster
  ]
}

module "ecs_services" {
  source = "../modules/ecs_service"

  for_each = { for k, v in local.ecs_workloads : k => v if v.external_access == true }

  resource_prefix  = local.resource_prefix
  additional_tags  = local.product_tags
  component_prefix = each.key

  deletion_protection = local.deletion_protection

  cluster_id                 = module.ecs_cluster.id
  task_definition_arn        = module.ecs_task_definitions[each.key].arn
  target_group_arn           = module.app_target_groups[each.key].target_group_blue_arn
  desired_count              = each.value.ecs.desired_count
  min_scale                  = each.value.ecs.min_scale
  max_scale                  = each.value.ecs.max_scale
  container_name             = each.value.ecs.container_name
  container_port             = each.value.ecs.container_port
  security_groups            = each.value.security_groups
  capacity_provider_strategy = each.value.ecs.capacity_provider_strategy
  subnets                    = module.vpc.private_subnets
}

module "ecs_services_not_lb" {
  source = "../modules/ecs_service"

  for_each = { for k, v in local.ecs_workloads : k => v if v.external_access == false }

  resource_prefix  = local.resource_prefix
  additional_tags  = local.product_tags
  component_prefix = each.key

  deletion_protection = local.deletion_protection

  cluster_id                 = module.ecs_cluster.id
  task_definition_arn        = module.ecs_task_definitions[each.key].arn
  target_group_arn           = null
  desired_count              = each.value.ecs.desired_count
  min_scale                  = each.value.ecs.min_scale
  max_scale                  = each.value.ecs.max_scale
  container_name             = null
  container_port             = null
  security_groups            = each.value.security_groups
  capacity_provider_strategy = each.value.ecs.capacity_provider_strategy
  subnets                    = module.vpc.private_subnets
}
