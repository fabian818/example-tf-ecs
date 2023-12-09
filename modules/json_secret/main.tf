resource "aws_secretsmanager_secret" "default" {
  name = "${local.prefix}-secret-${local.timestamp_sanitized}"

  lifecycle {
    ignore_changes = [
      name
    ]
  }
}

resource "aws_secretsmanager_secret_version" "default" {
  secret_id     = aws_secretsmanager_secret.default.id
  secret_string = jsonencode(var.values)
}
