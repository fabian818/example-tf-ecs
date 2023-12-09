resource "aws_iam_role" "codepipeline_role" {
  name               = "${local.prefix}-pipeline-role"
  assume_role_policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name = "codepipeline_policy"
  role = aws_iam_role.codepipeline_role.id

  policy = <<-EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect":"Allow",
      "Action": [
        "s3:GetObject",
        "s3:GetObjectVersion",
        "s3:GetBucketVersioning",
        "s3:PutObject"
      ],
      "Resource": [
        "${var.artifacts_bucket_arn}",
        "${var.artifacts_bucket_arn}/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "codebuild:BatchGetBuilds",
        "codebuild:StartBuild"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "codedeploy:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ecs:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:PassRole"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}


resource "aws_codepipeline" "default" {
  name     = "${local.prefix}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn
  tags = merge(var.additional_tags, {
    Name = "${local.prefix}-repo"
  })

  artifact_store {
    location = var.artifacts_bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      category = "Source"
      configuration = {
        "Branch"               = var.repository_branch
        "Owner"                = var.owner
        "PollForSourceChanges" = "false"
        "Repo"                 = var.github_repository_name
        "OAuthToken"           = data.aws_secretsmanager_secret_version.github_token.secret_string
      }
      input_artifacts = []
      name            = "Source"
      output_artifacts = [
        "SourceArtifact",
      ]
      owner     = "ThirdParty"
      provider  = "GitHub"
      run_order = 1
      version   = "1"
    }
  }
  stage {
    name = "Build"

    action {
      category = "Build"
      configuration = {
        "EnvironmentVariables" = jsonencode(
          concat(
            [
              {
                name  = "REPOSITORY_URI"
                type  = "PLAINTEXT"
                value = var.docker_repository_url
              },
              {
                name  = "TASK_DEFINITION"
                type  = "PLAINTEXT"
                value = var.task_definition
              },
              {
                name  = "TASK_DEFINITION_ARN"
                type  = "PLAINTEXT"
                value = join(":", slice(split(":", var.task_definition_arn), 0, 6))
              }
            ],
            var.build_env_vars
          )
        )
        "ProjectName" = aws_codebuild_project.default.name
      }
      input_artifacts = [
        "SourceArtifact",
      ]
      name = "Build"
      output_artifacts = [
        "BuildArtifact",
      ]
      owner     = "AWS"
      provider  = "CodeBuild"
      run_order = 1
      version   = "1"
    }
  }

  dynamic "stage" {
    for_each = var.migration_env_vars != null ? { x = "x" } : {}
    content {

      name = "RunMigration"

      action {
        category = "Build"
        configuration = {
          "EnvironmentVariables" = jsonencode(
            concat(var.migration_env_vars)
          )
          "ProjectName" = aws_codebuild_project.migration.name
        }
        input_artifacts = [
          "BuildArtifact",
        ]
        name = "RunMigration"
        output_artifacts = [
        ]
        owner     = "AWS"
        provider  = "CodeBuild"
        run_order = 1
        version   = "1"
      }

    }
  }
  stage {
    name = "Deploy"

    dynamic "action" {
      for_each = var.deployments

      content {
        name            = "${action.key}Deploy"
        category        = "Deploy"
        owner           = "AWS"
        provider        = "CodeDeployToECS"
        input_artifacts = ["BuildArtifact"]
        version         = "1"

        configuration = {
          ApplicationName                = aws_codedeploy_app.default.name
          DeploymentGroupName            = aws_codedeploy_deployment_group.default[action.key].deployment_group_name
          TaskDefinitionTemplateArtifact = "BuildArtifact"
          TaskDefinitionTemplatePath     = action.value.taskdef_file
          AppSpecTemplateArtifact        = "BuildArtifact"
          AppSpecTemplatePath            = action.value.appspec_file
        }
      }
    }
  }
  dynamic "stage" {
    for_each = var.parameter_name != null ? { x = "x" } : {}
    content {

      name = "SetParameter"

      action {
        category = "Build"
        configuration = {
          "EnvironmentVariables" = jsonencode(
            concat(
              [
                {
                  name  = "SSM_PARAMETER_NAME"
                  type  = "PLAINTEXT"
                  value = var.parameter_name
                }
              ]
            )
          )
          "ProjectName" = aws_codebuild_project.parameter.name
        }
        input_artifacts = [
          "SourceArtifact",
        ]
        name = "SetParameter"
        output_artifacts = [
        ]
        owner     = "AWS"
        provider  = "CodeBuild"
        run_order = 1
        version   = "1"
      }

    }
  }
}
