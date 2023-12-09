resource "aws_lb_listener_rule" "default" {
  listener_arn = var.listener_arn

  action {
    type             = "forward"
    target_group_arn = var.target_group_arn
  }

  condition {
    host_header {
      values = var.host_headers
    }
  }

  lifecycle {
    ignore_changes = [action]
  }

  tags = merge(var.additional_tags, {
    Name = "${local.prefix}-rule"
  })
}
