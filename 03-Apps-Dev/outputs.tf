output "cluster_name" {
  value = module.ecs_cluster.name
}

output "ecs_api_sg_id" {
  value = module.app-productstack.productstack-sg-ids["compute-api"].id
}

output "ecs_services" {
  value = {
    for k, obj in module.ecs_services : k => {
      name = obj.name
    }
  }
}

output "vpc_private_subnets" {
  value = [
    for k, obj in module.vpc.private_subnets : obj
  ]
}

output "ecs_task_definitions" {
  value = {
    for k, obj in module.ecs_task_definitions : k => {
      name               = obj.family
      arn                = obj.arn
      execution_role_arn = obj.execution_role_arn
      task_role_arn      = obj.task_role_arn
    }
  }
}

output "buckets" {
  value = {
    for k, obj in module.buckets : k => {
      id = obj.id
    }
  }
}

output "s3_cloudfront" {
  value = {
    for k, obj in module.s3_cloudfront : k => {
      id = obj.id
    }
  }
}

output "alb_listeners" {
  value = {
    for k, obj in module.albs : k => {
      http_listener_arn  = obj.http_listener_arn
      https_listener_arn = obj.https_listener_arn
    }
  }
}

output "alb_target_groups" {
  value = {
    for k, obj in module.app_target_groups : k => {
      target_group_blue_arn   = obj.target_group_blue_arn
      target_group_green_arn  = obj.target_group_green_arn
      target_group_blue_name  = obj.target_group_blue_name
      target_group_green_name = obj.target_group_green_name
    }
  }
}

output "base_api_url" {
  value = "https://api.${local.root_dns}"
}

output "collateral_transactions_refresh_interval" {
  value = "5000"
}