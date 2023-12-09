resource "aws_efs_file_system" "default" {
  tags = merge(var.additional_tags, {
    Name = "${local.prefix}-efs"
  })
}

resource "aws_efs_mount_target" "default" {
  file_system_id  = aws_efs_file_system.default.id
  subnet_id       = var.subnet_id
  security_groups = var.security_groups
}