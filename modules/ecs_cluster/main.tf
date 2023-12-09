resource "aws_ecs_cluster" "default" {
  name = "${local.prefix}-cluster"

  tags = merge(var.additional_tags, {
    Name = "${local.prefix}-cluster"
  })

}
