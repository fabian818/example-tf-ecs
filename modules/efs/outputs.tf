output "id" {
  value = aws_efs_file_system.default.id
}

output "dns_name" {
  value = aws_efs_mount_target.default.dns_name
}

output "mount_target_dns_name" {
  value = aws_efs_mount_target.default.mount_target_dns_name
}

output "file_system_arn" {
  value = aws_efs_mount_target.default.file_system_arn
}