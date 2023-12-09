data "terraform_remote_state" "juried-infra-general-shared-resources-01" {
  backend = "s3"
  config = {
    bucket = "terraform.infrastructure.main.juried.com"
    key    = "01-Shared-Resources/tf.state"
    region = "us-east-1"
  }
}


locals {
  ecr_repos = data.terraform_remote_state.juried-infra-general-shared-resources-01.outputs.ecr_repos
}