data "terraform_remote_state" "juried-infra-dev-apps-03" {
  backend = "s3"
  config = {
    bucket = "terraform.infrastructure.main.juried.com"
    key    = "03-Apps-Dev/tf.state"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "juried-infra-prod-apps-05" {
  backend = "s3"
  config = {
    bucket = "terraform.infrastructure.main.juried.com"
    key    = "05-Apps-Production/tf.state"
    region = "us-east-1"
  }
}

data "terraform_remote_state" "juried-infra-general-shared-resources-01" {
  backend = "s3"
  config = {
    bucket = "terraform.infrastructure.main.juried.com"
    key    = "01-Shared-Resources/tf.state"
    region = "us-east-1"
  }
}


locals {
  # Shared Resources outputs

  ecr_repos  = data.terraform_remote_state.juried-infra-general-shared-resources-01.outputs.ecr_repos
  s3_buckets = data.terraform_remote_state.juried-infra-general-shared-resources-01.outputs.s3_buckets

  # Dev outputs

  dev_cluster_name         = data.terraform_remote_state.juried-infra-dev-apps-03.outputs.cluster_name
  dev_ecs_api_sg_id        = data.terraform_remote_state.juried-infra-dev-apps-03.outputs.ecs_api_sg_id
  dev_vpc_private_subnets  = data.terraform_remote_state.juried-infra-dev-apps-03.outputs.vpc_private_subnets
  dev_ecs_services         = data.terraform_remote_state.juried-infra-dev-apps-03.outputs.ecs_services
  dev_ecs_task_definitions = data.terraform_remote_state.juried-infra-dev-apps-03.outputs.ecs_task_definitions
  dev_buckets              = data.terraform_remote_state.juried-infra-dev-apps-03.outputs.buckets
  dev_s3_cloudfront        = data.terraform_remote_state.juried-infra-dev-apps-03.outputs.s3_cloudfront
  dev_alb_listeners        = data.terraform_remote_state.juried-infra-dev-apps-03.outputs.alb_listeners
  dev_alb_target_groups    = data.terraform_remote_state.juried-infra-dev-apps-03.outputs.alb_target_groups
  dev_base_api_url         = data.terraform_remote_state.juried-infra-dev-apps-03.outputs.base_api_url

  # Prod outputs

  prod_cluster_name         = data.terraform_remote_state.juried-infra-prod-apps-05.outputs.cluster_name
  prod_ecs_api_sg_id        = data.terraform_remote_state.juried-infra-prod-apps-05.outputs.ecs_api_sg_id
  prod_vpc_private_subnets  = data.terraform_remote_state.juried-infra-prod-apps-05.outputs.vpc_private_subnets
  prod_ecs_services         = data.terraform_remote_state.juried-infra-prod-apps-05.outputs.ecs_services
  prod_ecs_task_definitions = data.terraform_remote_state.juried-infra-prod-apps-05.outputs.ecs_task_definitions
  prod_buckets              = data.terraform_remote_state.juried-infra-prod-apps-05.outputs.buckets
  prod_s3_cloudfront        = data.terraform_remote_state.juried-infra-prod-apps-05.outputs.s3_cloudfront
  prod_alb_listeners        = data.terraform_remote_state.juried-infra-prod-apps-05.outputs.alb_listeners
  prod_alb_target_groups    = data.terraform_remote_state.juried-infra-prod-apps-05.outputs.alb_target_groups
  prod_base_api_url         = data.terraform_remote_state.juried-infra-prod-apps-05.outputs.base_api_url
}
