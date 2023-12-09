locals {
  resource_prefix = "juried-infra-shared"
  aws_region      = "us-east-1"

  default_tags = {
    Owner     = "Devops"
    Env       = "Shared"
    Terraform = "True"
  }

  product_tags = merge(local.default_tags, {
    product = "general"
  })

  deletion_protection = true

  ecr_repos = {
    api     = {}
    lambdas = {}
  }

  s3_buckets = {
    artifacts-bucket = {}
  }
}
