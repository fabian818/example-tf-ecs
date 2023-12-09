output "dns_name" {
  value = aws_lb.default.dns_name
}

output "id" {
  value = aws_lb.default.id
}

output "listeners" {
  value = {
    for k, obj in aws_lb_listener.default : k => {
      arn = obj.arn
    }
  }
}

output "target_groups" {
  value = {
    for k, obj in aws_lb_target_group.default : k => {
      arn  = obj.arn
      name = obj.name
    }
  }
}
