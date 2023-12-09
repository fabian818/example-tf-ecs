data "aws_secretsmanager_secret" "github_token" {
  name = var.github_token_name
}

data "aws_secretsmanager_secret_version" "github_token" {
  secret_id = data.aws_secretsmanager_secret.github_token.id
}

terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}

resource "aws_codepipeline_webhook" "codepipeline_webhook" {
  authentication  = "GITHUB_HMAC"
  name            = "${local.prefix}-codepipeline-webhook"
  target_action   = "Source"
  target_pipeline = aws_codepipeline.default.name

  authentication_configuration {
    secret_token = data.aws_secretsmanager_secret_version.github_token.secret_string
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/${var.repository_branch}"
  }

  tags = merge(var.additional_tags, {
    Name = "${local.prefix}-cf-distribution"
  })
}


resource "github_repository_webhook" "default" {
  repository = var.github_repository_name

  configuration {
    url          = aws_codepipeline_webhook.codepipeline_webhook.url
    content_type = "json"
    insecure_ssl = true
    secret       = data.aws_secretsmanager_secret_version.github_token.secret_string
  }

  events = ["push"]
}
