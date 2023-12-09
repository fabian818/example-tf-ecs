output "productstack-sg-ids" {
  description = "productstack security group ids"
  value = {
    for k, obj in var.components : k => {
      name = obj.name
      id   = aws_security_group.productstack_components[k].id
    }
  }
}
