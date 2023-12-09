data "template_file" "api_dev_buildspec" {
  template = file("files/dev/api-buildspec.yml")
}

data "template_file" "migrate_dev_buildspec" {
  template = file("files/dev/migrate-buildspec.yml")
}

data "template_file" "frontend_dev_buildspec" {
  template = file("files/dev/frontend-buildspec.yml")
}

data "template_file" "api_prod_buildspec" {
  template = file("files/prod/api-buildspec.yml")
}

data "template_file" "migrate_prod_buildspec" {
  template = file("files/prod/migrate-buildspec.yml")
}

data "template_file" "frontend_prod_buildspec" {
  template = file("files/prod/frontend-buildspec.yml")
}

data "aws_secretsmanager_secret" "github_token" {
  name = local.cicd.github.github_token_name
}

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = data.aws_secretsmanager_secret.github_token.id
}
