resource "aws_codepipeline" "default" {
  name     = "${local.prefix}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  tags = merge(var.additional_tags, {
    Name = "${local.prefix}-repo"
  })

  artifact_store {
    location = split(":", var.artifacts_bucket_arn)[5]
    type     = "S3"
  }

  dynamic "stage" {
    for_each = var.stages

    content {
      name = stage.value["name"]

      dynamic "action" {
        for_each = stage.value["actions"]

        content {
          category         = action.value["category"]
          configuration    = action.value["configuration"]
          input_artifacts  = action.value["input_artifacts"]
          name             = action.value["name"]
          output_artifacts = action.value["output_artifacts"]
          owner            = action.value["owner"]
          provider         = action.value["provider"]
          version          = "1"
        }
      }
    }
  }
}




#   action {
#     category = "Source"
#     configuration = {
#       "Branch"               = var.repository_branch
#       "Owner"                = var.owner
#       "PollForSourceChanges" = "false"
#       "Repo"                 = var.github_repository_name
#       "OAuthToken"           = data.aws_secretsmanager_secret_version.github_token.secret_string
#     }
#     input_artifacts = []
#     name            = "Source"
#     output_artifacts = [
#       "SourceArtifact",
#     ]
#     owner     = "ThirdParty"
#     provider  = "GitHub"
#     run_order = 1
#     version   = "1"
#   }
# }
# stage {
#   name = "Build"

#   action {
#     category = "Build"
#     configuration = {
#       "EnvironmentVariables" = jsonencode(
#         concat(
#           [
#             {
#               name  = "REPOSITORY_URI"
#               type  = "PLAINTEXT"
#               value = var.docker_repository_url
#             },
#             {
#               name  = "TASK_DEFINITION"
#               type  = "PLAINTEXT"
#               value = var.task_definition
#             },
#             {
#               name  = "TASK_DEFINITION_ARN"
#               type  = "PLAINTEXT"
#               value = join(":", slice(split(":", var.task_definition_arn), 0, 6))
#             }
#           ],
#           var.build_env_vars
#         )
#       )
#       "ProjectName" = aws_codebuild_project.default.name
#     }
#     input_artifacts = [
#       "SourceArtifact",
#     ]
#     name = "Build"
#     output_artifacts = [
#       "BuildArtifact",
#     ]
#     owner     = "AWS"
#     provider  = "CodeBuild"
#     run_order = 1
#     version   = "1"
#   }
# }

# dynamic "stage" {
#   for_each = var.migration_env_vars != null ? { x = "x" } : {}
#   content {

#     name = "RunMigration"

#     action {
#       category = "Build"
#       configuration = {
#         "EnvironmentVariables" = jsonencode(
#           concat(var.migration_env_vars)
#         )
#         "ProjectName" = aws_codebuild_project.migration.name
#       }
#       input_artifacts = [
#         "BuildArtifact",
#       ]
#       name = "RunMigration"
#       output_artifacts = [
#       ]
#       owner     = "AWS"
#       provider  = "CodeBuild"
#       run_order = 1
#       version   = "1"
#     }

#   }
# }
# stage {
#   name = "Deploy"

#   dynamic "action" {
#     for_each = var.deployments

#     content {
#       name            = "${action.key}Deploy"
#       category        = "Deploy"
#       owner           = "AWS"
#       provider        = "CodeDeployToECS"
#       input_artifacts = ["BuildArtifact"]
#       version         = "1"

#       configuration = {
#         ApplicationName                = aws_codedeploy_app.default.name
#         DeploymentGroupName            = aws_codedeploy_deployment_group.default[action.key].deployment_group_name
#         TaskDefinitionTemplateArtifact = "BuildArtifact"
#         TaskDefinitionTemplatePath     = action.value.taskdef_file
#         AppSpecTemplateArtifact        = "BuildArtifact"
#         AppSpecTemplatePath            = action.value.appspec_file
#       }
#     }
#   }
# }
# dynamic "stage" {
#   for_each = var.parameter_name != null ? { x = "x" } : {}
#   content {

#     name = "SetParameter"

#     action {
#       category = "Build"
#       configuration = {
#         "EnvironmentVariables" = jsonencode(
#           concat(
#             [
#               {
#                 name  = "SSM_PARAMETER_NAME"
#                 type  = "PLAINTEXT"
#                 value = var.parameter_name
#               }
#             ]
#           )
#         )
#         "ProjectName" = aws_codebuild_project.parameter.name
#       }
#       input_artifacts = [
#         "SourceArtifact",
#       ]
#       name = "SetParameter"
#       output_artifacts = [
#       ]
#       owner     = "AWS"
#       provider  = "CodeBuild"
#       run_order = 1
#       version   = "1"
#     }

#   }

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
    secret_token = var.stages[0].actions.source.configuration["OAuthToken"]
  }

  filter {
    json_path    = "$.ref"
    match_equals = "refs/heads/${var.stages[0].actions.source.configuration["Branch"]}"
  }

  tags = merge(var.additional_tags, {
    Name = "${local.prefix}-cf-distribution"
  })
}


resource "github_repository_webhook" "default" {
  repository = var.stages[0].actions.source.configuration["Repo"]

  configuration {
    url          = aws_codepipeline_webhook.codepipeline_webhook.url
    content_type = "json"
    insecure_ssl = true
    secret       = var.stages[0].actions.source.configuration["OAuthToken"]
  }

  events = ["push"]
}
