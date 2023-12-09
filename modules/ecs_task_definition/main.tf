resource "aws_cloudwatch_log_group" "default" {
  name = "${local.prefix}-log-group"

  tags = merge(var.additional_tags, {
    Name = "${local.prefix}-log-group"
  })
}

resource "aws_ecs_task_definition" "default" {
  family                   = "${local.prefix}-td"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  execution_role_arn       = aws_iam_role.execution_role.arn
  task_role_arn            = aws_iam_role.task_role.arn
  cpu                      = var.cpu
  memory                   = var.memory
  container_definitions = jsonencode([
    {
      name        = "main"
      image       = var.image_url
      command     = var.command
      cpu         = var.cpu
      memory      = var.memory
      essential   = true
      mountPoints = []
      volumesFrom = []
      portMappings = [
        {
          containerPort = var.container_port
          hostPort      = var.container_port
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.default.name,
          awslogs-region        = var.aws_region,
          awslogs-stream-prefix = "ecs"
        }
      }
      environment = var.environment_variables
      secrets     = var.secrets
      mountPoints = var.mount_points
    }
  ])
  dynamic "volume" {
    for_each = var.volume_name != null ? [1] : []

    content {
      name = var.volume_name
      efs_volume_configuration {
        file_system_id = var.file_system_id
        root_directory = var.volume_directory
      }
    }
  }
}
