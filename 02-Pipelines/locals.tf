locals {
  resource_prefix = "juried-infra-shared"
  aws_region      = "us-east-1"

  default_tags = {
    Owner     = "Devops"
    Env       = "Shared"
    Terraform = "True"
  }

  product_tags = merge(local.default_tags, {
    product = "pipelines"
  })

  deletion_protection = false

  cicd = {
    github = {
      github_token_name = "juried-platform-oauth-token-secret"
      owner             = "Juried"
    }
  }

  codebuild = {
    # dev-api = {
    #   buildspec_content = data.template_file.api_dev_buildspec.rendered
    #   image             = "aws/codebuild/standard:4.0"
    # }
    # dev-migrate = {
    #   buildspec_content = data.template_file.migrate_dev_buildspec.rendered
    #   image             = "aws/codebuild/standard:5.0"
    # }
    # dev-frontend = {
    #   buildspec_content = data.template_file.frontend_dev_buildspec.rendered
    #   image             = "aws/codebuild/standard:5.0"
    # }

    # prod-api = {
    #   buildspec_content = data.template_file.api_prod_buildspec.rendered
    #   image             = "aws/codebuild/standard:4.0"
    # }
    # prod-migrate = {
    #   buildspec_content = data.template_file.migrate_prod_buildspec.rendered
    #   image             = "aws/codebuild/standard:5.0"
    # }
    # prod-frontend = {
    #   buildspec_content = data.template_file.frontend_prod_buildspec.rendered
    #   image             = "aws/codebuild/standard:5.0"
    # }
  }

  pipelines = {

    # Dev pipelines

    # api-dev = {
    #   artifacts_bucket_arn = local.s3_buckets["artifacts-bucket"].arn
    #   stages = {
    #     0 = {
    #       name = "Source"
    #       actions = {
    #         source = {
    #           category = "Source"
    #           configuration = {
    #             "Branch"               = "dev"
    #             "Owner"                = "Juried"
    #             "PollForSourceChanges" = "false"
    #             "Repo"                 = "juried-backend"
    #             "OAuthToken"           = data.aws_secretsmanager_secret_version.github_token.secret_string
    #           }
    #           input_artifacts = []
    #           name            = "Source"
    #           output_artifacts = [
    #             "SourceArtifact",
    #           ]
    #           owner    = "ThirdParty"
    #           provider = "GitHub"
    #         }
    #       }
    #     }
    #     1 = {
    #       name = "Build"
    #       actions = {
    #         build = {
    #           category = "Build"
    #           configuration = {
    #             "EnvironmentVariables" = jsonencode(
    #               concat(
    #                 [
    #                   {
    #                     name  = "IMAGE_REPO_NAME"
    #                     type  = "PLAINTEXT"
    #                     value = local.ecr_repos["api"].repository_url
    #                   }
    #                 ]
    #               )
    #             )
    #             "ProjectName" = module.codebuild["dev-api"].name
    #           }
    #           input_artifacts = [
    #             "SourceArtifact",
    #           ]
    #           name = "Build"
    #           output_artifacts = [
    #             "BuildArtifact",
    #           ]
    #           owner    = "AWS"
    #           provider = "CodeBuild"
    #         }
    #       }
    #     }
    #     2 = {
    #       name = "Deploy"
    #       actions = {
    #         deploy = {
    #           category = "Deploy"
    #           configuration = {
    #             ClusterName = local.dev_cluster_name
    #             ServiceName = local.dev_ecs_services["api"].name
    #           }
    #           name = "Deploy"
    #           input_artifacts = [
    #             "BuildArtifact"
    #           ]
    #           output_artifacts = []
    #           owner            = "AWS"
    #           provider         = "ECS"
    #         }
    #       }
    #     }
    #     3 = {
    #       name = "Migrate"
    #       actions = {
    #         migrate = {
    #           category = "Build"
    #           configuration = {
    #             "EnvironmentVariables" = jsonencode(
    #               concat(
    #                 [
    #                   {
    #                     name  = "TASK_DEFINITION_FAMILY"
    #                     type  = "PLAINTEXT"
    #                     value = local.dev_ecs_task_definitions["api"].name
    #                   },
    #                   {
    #                     name  = "ECS_CLUSTER"
    #                     type  = "PLAINTEXT"
    #                     value = local.dev_cluster_name
    #                   },
    #                   {
    #                     name  = "ECS_SUBNET_ID"
    #                     type  = "PLAINTEXT"
    #                     value = local.dev_vpc_private_subnets[0]
    #                   },
    #                   {
    #                     name  = "ECS_SERVICE_SECURITY_GROUP_ID"
    #                     type  = "PLAINTEXT"
    #                     value = local.dev_ecs_api_sg_id
    #                   }
    #                 ]
    #               )
    #             )
    #             "ProjectName" = module.codebuild["dev-migrate"].name
    #           }
    #           input_artifacts = [
    #             "SourceArtifact",
    #           ]
    #           name             = "Build"
    #           output_artifacts = []
    #           owner            = "AWS"
    #           provider         = "CodeBuild"
    #         }
    #       }
    #     }
    #   }
    # }

    # frontend-dev = {
    #   artifacts_bucket_arn = local.s3_buckets["artifacts-bucket"].arn
    #   stages = {
    #     0 = {
    #       name = "Source"
    #       actions = {
    #         source = {
    #           category = "Source"
    #           configuration = {
    #             "Branch"               = "dev"
    #             "Owner"                = "Juried"
    #             "PollForSourceChanges" = "false"
    #             "Repo"                 = "juried-frontend"
    #             "OAuthToken"           = data.aws_secretsmanager_secret_version.github_token.secret_string
    #           }
    #           input_artifacts = []
    #           name            = "Source"
    #           output_artifacts = [
    #             "SourceArtifact",
    #           ]
    #           owner    = "ThirdParty"
    #           provider = "GitHub"
    #         }
    #       }
    #     }
    #     1 = {
    #       name = "Build"
    #       actions = {
    #         build = {
    #           category = "Build"
    #           configuration = {
    #             "EnvironmentVariables" = jsonencode(
    #               concat(
    #                 [
    #                   {
    #                     name  = "BUCKET_NAME"
    #                     type  = "PLAINTEXT"
    #                     value = local.dev_buckets["frontend"].id
    #                   },
    #                   {
    #                     name  = "REACT_APP_API_URI"
    #                     type  = "PLAINTEXT"
    #                     value = local.dev_base_api_url
    #                   },
    #                   {
    #                     name  = "GENERATE_SOURCEMAP"
    #                     type  = "PLAINTEXT"
    #                     value = "false"
    #                   },
    #                   {
    #                     name  = "DISTRIBUTION_ID"
    #                     type  = "PLAINTEXT"
    #                     value = local.dev_s3_cloudfront["frontend"].id
    #                   }
    #                 ]
    #               )
    #             )
    #             "ProjectName" = module.codebuild["dev-frontend"].name
    #           }
    #           input_artifacts = [
    #             "SourceArtifact",
    #           ]
    #           name = "Build"
    #           output_artifacts = [
    #             "BuildArtifact",
    #           ]
    #           owner    = "AWS"
    #           provider = "CodeBuild"
    #         }
    #       }
    #     }
    #   }
    # }

    # Prod pipelines

    # api-prod = {
    #   artifacts_bucket_arn = local.s3_buckets["artifacts-bucket"].arn
    #   stages = {
    #     0 = {
    #       name = "Source"
    #       actions = {
    #         source = {
    #           category = "Source"
    #           configuration = {
    #             "Branch"               = "main"
    #             "Owner"                = "Juried"
    #             "PollForSourceChanges" = "false"
    #             "Repo"                 = "juried-backend"
    #             "OAuthToken"           = data.aws_secretsmanager_secret_version.github_token.secret_string
    #           }
    #           input_artifacts = []
    #           name            = "Source"
    #           output_artifacts = [
    #             "SourceArtifact",
    #           ]
    #           owner    = "ThirdParty"
    #           provider = "GitHub"
    #         }
    #       }
    #     }
    #     1 = {
    #       name = "Build"
    #       actions = {
    #         build = {
    #           category = "Build"
    #           configuration = {
    #             "EnvironmentVariables" = jsonencode(
    #               concat(
    #                 [
    #                   {
    #                     name  = "IMAGE_REPO_NAME"
    #                     type  = "PLAINTEXT"
    #                     value = local.ecr_repos["api"].repository_url
    #                   }
    #                 ]
    #               )
    #             )
    #             "ProjectName" = module.codebuild["prod-api"].name
    #           }
    #           input_artifacts = [
    #             "SourceArtifact",
    #           ]
    #           name = "Build"
    #           output_artifacts = [
    #             "BuildArtifact",
    #           ]
    #           owner    = "AWS"
    #           provider = "CodeBuild"
    #         }
    #       }
    #     }
    #     2 = {
    #       name = "Deploy"
    #       actions = {
    #         deploy = {
    #           category = "Deploy"
    #           configuration = {
    #             ClusterName = local.prod_cluster_name
    #             ServiceName = local.prod_ecs_services["api"].name
    #           }
    #           name = "Deploy"
    #           input_artifacts = [
    #             "BuildArtifact"
    #           ]
    #           output_artifacts = []
    #           owner            = "AWS"
    #           provider         = "ECS"
    #         }
    #       }
    #     }
    #     3 = {
    #       name = "Migrate"
    #       actions = {
    #         migrate = {
    #           category = "Build"
    #           configuration = {
    #             "EnvironmentVariables" = jsonencode(
    #               concat(
    #                 [
    #                   {
    #                     name  = "TASK_DEFINITION_FAMILY"
    #                     type  = "PLAINTEXT"
    #                     value = local.prod_ecs_task_definitions["api"].name
    #                   },
    #                   {
    #                     name  = "ECS_CLUSTER"
    #                     type  = "PLAINTEXT"
    #                     value = local.prod_cluster_name
    #                   },
    #                   {
    #                     name  = "ECS_SUBNET_ID"
    #                     type  = "PLAINTEXT"
    #                     value = local.prod_vpc_private_subnets[0]
    #                   },
    #                   {
    #                     name  = "ECS_SERVICE_SECURITY_GROUP_ID"
    #                     type  = "PLAINTEXT"
    #                     value = local.prod_ecs_api_sg_id
    #                   }
    #                 ]
    #               )
    #             )
    #             "ProjectName" = module.codebuild["prod-migrate"].name
    #           }
    #           input_artifacts = [
    #             "SourceArtifact",
    #           ]
    #           name             = "Build"
    #           output_artifacts = []
    #           owner            = "AWS"
    #           provider         = "CodeBuild"
    #         }
    #       }
    #     }
    #   }
    # }

    # frontend-prod = {
    #   artifacts_bucket_arn = local.s3_buckets["artifacts-bucket"].arn
    #   stages = {
    #     0 = {
    #       name = "Source"
    #       actions = {
    #         source = {
    #           category = "Source"
    #           configuration = {
    #             "Branch"               = "main"
    #             "Owner"                = "Juried"
    #             "PollForSourceChanges" = "false"
    #             "Repo"                 = "juried-frontend"
    #             "OAuthToken"           = data.aws_secretsmanager_secret_version.github_token.secret_string
    #           }
    #           input_artifacts = []
    #           name            = "Source"
    #           output_artifacts = [
    #             "SourceArtifact",
    #           ]
    #           owner    = "ThirdParty"
    #           provider = "GitHub"
    #         }
    #       }
    #     }
    #     1 = {
    #       name = "Build"
    #       actions = {
    #         build = {
    #           category = "Build"
    #           configuration = {
    #             "EnvironmentVariables" = jsonencode(
    #               concat(
    #                 [
    #                   {
    #                     name  = "BUCKET_NAME"
    #                     type  = "PLAINTEXT"
    #                     value = local.prod_buckets["frontend"].id
    #                   },
    #                   {
    #                     name  = "REACT_APP_API_URI"
    #                     type  = "PLAINTEXT"
    #                     value = local.prod_base_api_url
    #                   },
    #                   {
    #                     name  = "GENERATE_SOURCEMAP"
    #                     type  = "PLAINTEXT"
    #                     value = "false"
    #                   },
    #                   {
    #                     name  = "DISTRIBUTION_ID"
    #                     type  = "PLAINTEXT"
    #                     value = local.prod_s3_cloudfront["frontend"].id
    #                   }
    #                 ]
    #               )
    #             )
    #             "ProjectName" = module.codebuild["dev-frontend"].name
    #           }
    #           input_artifacts = [
    #             "SourceArtifact",
    #           ]
    #           name = "Build"
    #           output_artifacts = [
    #             "BuildArtifact",
    #           ]
    #           owner    = "AWS"
    #           provider = "CodeBuild"
    #         }
    #       }
    #     }
    #   }
    # }
  }
}
