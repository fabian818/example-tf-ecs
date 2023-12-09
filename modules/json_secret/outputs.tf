output "secret_arn" {
  value = aws_secretsmanager_secret.default.arn
}

output "secret_name" {
  value = aws_secretsmanager_secret.default.name
}
