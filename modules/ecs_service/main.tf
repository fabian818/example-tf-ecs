resource "aws_ecs_service" "default" {
  name                   = "${local.prefix}-service"
  cluster                = var.cluster_id
  task_definition        = var.task_definition_arn
  desired_count          = var.desired_count
  enable_execute_command = true

  dynamic "load_balancer" {
    for_each = var.target_group_arn != null ? [1] : []
    content {
      target_group_arn = var.target_group_arn
      container_name   = var.container_name
      container_port   = var.container_port
    }
  }

  network_configuration {
    security_groups = var.security_groups
    subnets         = var.subnets
  }

  dynamic "capacity_provider_strategy" {
    for_each = var.capacity_provider_strategy
    content {
      capacity_provider = capacity_provider_strategy.value.capacity_provider
      weight            = capacity_provider_strategy.value.weight
      base              = lookup(capacity_provider_strategy.value, "base", null)
    }
  }

  tags = merge(var.additional_tags, {
    Name = "${local.prefix}-service"
  })

  lifecycle {
    ignore_changes = [
      load_balancer,
      desired_count,
      task_definition,
    ]
    create_before_destroy = true
  }
}

resource "aws_appautoscaling_target" "default" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.cluster_id}/${aws_ecs_service.default.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.min_scale
  max_capacity       = var.max_scale
}
