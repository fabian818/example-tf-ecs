terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}

provider "github" {
  owner = local.cicd.github.owner
  token = data.aws_secretsmanager_secret_version.github_token.secret_string
}

provider "aws" {
  region = "us-east-1"
}
