data "aws_secretsmanager_secret" "juried-api" {
  arn = local.juried_api_secret
}

data "aws_secretsmanager_secret_version" "juried-api" {
  secret_id = data.aws_secretsmanager_secret.juried-api.id
}