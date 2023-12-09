resource "aws_lb_target_group" "blue" {
  port        = var.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    port                = var.port
    path                = var.health_check_path
    matcher             = var.health_check_status
    healthy_threshold   = 10
    unhealthy_threshold = 10
    interval            = 60
  }

  tags = merge(var.additional_tags, {
    Name = "${local.prefix}-blue-tg"
  })
}

resource "aws_lb_target_group" "green" {
  port        = var.port
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    port                = var.port
    path                = var.health_check_path
    matcher             = var.health_check_status
    healthy_threshold   = 10
    unhealthy_threshold = 10
    interval            = 60
  }

  tags = merge(var.additional_tags, {
    Name = "${local.prefix}-green-tg"
  })
}
