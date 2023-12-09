resource "aws_lb_target_group" "default" {
  port        = var.port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    enabled = var.health_check_enabled
    port    = var.health_check_port
    path    = var.health_check_path
    matcher = var.health_check_status
  }

  tags = merge(var.additional_tags, {
    Name = "${local.prefix}-blue-tg"
  })
}

resource "aws_lb_target_group_attachment" "default" {
  target_group_arn = aws_lb_target_group.default.arn
  target_id        = var.instance_id
  port             = var.port
}
