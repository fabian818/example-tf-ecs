resource "aws_lb" "default" {
  internal           = var.internal
  load_balancer_type = "network"
  subnets            = var.subnets

  enable_deletion_protection = var.enable_deletion_protection

  tags = merge(var.additional_tags, {
    Name = "${local.prefix}-vpn-nlb"
  })
}

resource "aws_lb_listener" "default" {
  for_each = var.ports

  load_balancer_arn = aws_lb.default.arn
  port              = each.value.port
  protocol          = each.value.protocol
  ssl_policy        = each.value.uses_certificate ? "ELBSecurityPolicy-2016-08" : null
  certificate_arn   = each.value.uses_certificate ? var.certificate_arn : null

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.default[each.key].arn
  }
}

resource "aws_lb_target_group" "default" {
  for_each = var.ports

  port        = each.value.port
  protocol    = each.value.protocol
  vpc_id      = var.vpc_id
  target_type = "instance"

  health_check {
    enabled  = true
    protocol = each.value.protocol_hc
    port     = each.value.port_hc
  }

  stickiness {
    enabled = false
    type    = "source_ip"
  }
}

resource "aws_lb_target_group_attachment" "default" {
  for_each = var.ports

  target_group_arn = aws_lb_target_group.default[each.key].arn
  target_id        = var.instance_id
  port             = each.value.port
}
