locals {
  resource_prefix = "juried-infra-prod"
  aws_region      = "us-east-1"

  default_tags = {
    Owner     = "Devops"
    Env       = "Prod"
    Terraform = "True"
  }

  product_tags = merge(local.default_tags, {
    product = "app"
  })

  deletion_protection = true

  # Previously defined locals

  root_dns          = "plataformajuried.com"
  zone_id           = "Z04717442OKW6H739P88D"
  certificate_arn   = "arn:aws:acm:us-east-1:901139450627:certificate/71e2125e-f315-484a-aa31-2c8fbb990479"
  juried_api_secret = "arn:aws:secretsmanager:us-east-1:901139450627:secret:prod/juried-api/secrets-m6d44H"
  bastion_key_name  = "juried-infra-prod-general-bastion-kp"
  vpc_octet         = "2"
  api_dns           = "api.${local.root_dns}"
  dv_dns            = "dv.${local.root_dns}"
  frontend_dns      = "app.${local.root_dns}"

  vpc = {
    cidr               = "11.${local.vpc_octet}.0.0/16"
    azs                = ["us-east-1a", "us-east-1b"]
    private_subnets    = ["11.${local.vpc_octet}.1.0/24", "11.${local.vpc_octet}.2.0/24"]
    public_subnets     = ["11.${local.vpc_octet}.101.0/24", "11.${local.vpc_octet}.102.0/24"]
    single_nat_gateway = false
  }

  albs = {
    public = {
      subnets         = module.vpc.public_subnets
      internal        = false
      logs_bucket     = null
      certificate_arn = local.certificate_arn
      security_groups = [module.app-productstack.productstack-sg-ids["alb-public"].id]
    }
  }

  ec2_instances = {
    bastion = {
      ami                    = "ami-006dcf34c09e50022"
      instance_type          = "t3.nano"
      create_spot_instance   = false
      key_name               = local.bastion_key_name
      vpc_security_group_ids = [module.app-productstack.productstack-sg-ids["compute-bastion"].id]
      subnet_id              = module.vpc.public_subnets[0]
    }
  }

  rds = {
    default = {
      engine                  = "postgres"
      engine_version          = "14.6"
      subnet_ids              = module.vpc.private_subnets
      vpc_security_group_ids  = [module.app-productstack.productstack-sg-ids["storage-default-rds"].id]
      database_name           = "juriedproddb"
      master_username         = "juriedproduser"
      backup_retention_period = 1
      kms_key_id              = module.rds_kms_key.arn
      instance_class          = "db.t3.small"
      allocated_storage       = 10
      deletion_protection     = local.deletion_protection
      skip_final_snapshot     = !local.deletion_protection
    }
  }

  buckets = {
    frontend = {}
    public   = {}
  }

  cloudfront = {
    frontend = {
      aliases            = [local.frontend_dns]
      certificate_arn    = local.certificate_arn
      bucket_arn         = module.buckets["frontend"].arn
      bucket_domain_name = module.buckets["frontend"].bucket_domain_name
      cache_policy_id    = "Managed-CachingOptimized"
    }
    public = {
      aliases            = ["public.${local.root_dns}"]
      certificate_arn    = local.certificate_arn
      bucket_arn         = module.buckets["public"].arn
      bucket_domain_name = module.buckets["public"].bucket_domain_name
      cache_policy_id    = "Managed-CachingOptimized"
    }
  }

  records = {
    api = {
      dns     = local.api_dns
      type    = "CNAME"
      ttl     = 600
      records = [module.albs["public"].dns_name]
    }
    dv = {
      dns     = local.dv_dns
      type    = "CNAME"
      ttl     = 600
      records = [module.albs["public"].dns_name]
    }
    frontend = {
      dns     = local.frontend_dns
      type    = "CNAME"
      ttl     = 600
      records = [module.s3_cloudfront["frontend"].domain_name]
    }
    public = {
      dns     = "public.${local.root_dns}"
      type    = "CNAME"
      ttl     = 600
      records = [module.s3_cloudfront["public"].domain_name]
    }
    bastion = {
      dns     = "bastion.${local.root_dns}"
      type    = "A"
      ttl     = 600
      records = [module.ec2_instances["bastion"].public_ip]
    }
  }

  ecs_workloads = {
    api = {
      host_header     = local.api_dns
      external_access = true
      cdn_type        = "non-cached"
      backend_type    = "ecs"
      security_groups = [module.app-productstack.productstack-sg-ids["compute-api"].id]
      alb = {
        listener_arn        = module.albs["public"].https_listener_arn
        health_check_path   = "/healthcheck"
        health_check_status = 200
      }
      ecs = {
        capacity_provider_strategy = [
          {
            capacity_provider = "FARGATE_SPOT",
            weight            = 100
          }
        ]
        image_url      = "${local.ecr_repos["api"].repository_url}:prod-latest"
        cpu            = 256
        memory         = 512
        desired_count  = 2
        container_name = "main"
        container_port = 3000
        min_scale      = 2
        max_scale      = 10
        target_memory  = 80
        target_cpu     = 45
        command        = ["bundle", "exec", "puma", "-C", "config/puma.rb"]

        mount_points     = []
        file_system_id   = null
        volume_directory = null
        volume_name      = null

        environment_variables = [
          {
            name  = "WEB_HOST"
            value = local.api_dns
          },
          {
            name  = "BACKEND_DOMAIN"
            value = local.api_dns
          },
          {
            name  = "SES_HOST"
            value = "email-smtp.us-east-1.amazonaws.com"
          },
          {
            name  = "APP_ENV"
            value = "app"
          },
          {
            name  = "FREEMIUM_COURSES_LIMIT"
            value = "3"
          },
          {
            name  = "FREEMIUM_STUDENTS_LIMIT"
            value = "20"
          },
          {
            name  = "FREEMIUM_MISSIONS_LIMIT"
            value = "3"
          },
          {
            name  = "FREEMIUM_COURSE_BADGES_LIMIT"
            value = "10"
          },
          {
            name  = "FREEMIUM_LEVELS_LIMIT"
            value = "5"
          },
          {
            name  = "FREEMIUM_BEHAVIORS_LIMIT"
            value = "6"
          },
          {
            name  = "PREMIUM_B2C_STUDENTS_LIMIT",
            value = "150"
          },
          {
            name  = "CULQI_URI",
            value = "https://api.culqi.com/v2/"
          },
          {
            name  = "SWAGGER_USER_NAME",
            value = "swagger_user"
          },
          {
            name  = "SWAGGER_PASSWORD",
            value = "AiMJYoiIYT"
          },
          {
            name  = "SCHEDULER_LAMBDA_ARN"
            value = module.docker-lambdas["python-main"].arn
          },
          {
            name  = "SCHEDULER_IAM_ROLE_ARN"
            value = module.docker-lambdas-scheduling-permissions["python-main"].role_arn
          },
          {
            name  = "CONFIRM_SUCCESS_URL"
            value = "https://app.plataformajuried.com/confirmation"
          }
        ]
        secrets = [
          {
            name      = "SECRET_KEY_BASE"
            valueFrom = "${local.juried_api_secret}:SECRET_KEY_BASE::"
          },
          {
            name      = "SES_SMTP_USERNAME"
            valueFrom = "${local.juried_api_secret}:SES_SMTP_USERNAME::"
          },
          {
            name      = "SES_SMTP_PASSWORD"
            valueFrom = "${local.juried_api_secret}:SES_SMTP_PASSWORD::"
          },
          {
            name      = "SENTRY_DNS"
            valueFrom = "${local.juried_api_secret}:SENTRY_DNS::"
          },
          {
            name      = "S3_BUCKET"
            valueFrom = "${local.juried_api_secret}:S3_BUCKET::"
          },
          {
            name      = "CULQI_PRIVATE_KEY"
            valueFrom = "${local.juried_api_secret}:CULQI_PRIVATE_KEY::"
          },
          {
            name      = "WEBHOOK_PERMITTED_KEY"
            valueFrom = "${local.juried_api_secret}:WEBHOOK_PERMITTED_KEY::"
          },
          {
            name      = "SCHEDULER_PERMITTED_KEYS"
            valueFrom = "${local.juried_api_secret}:SCHEDULER_PERMITTED_KEYS::"
          },
          {
            name      = "DB_USERNAME"
            valueFrom = "${module.rds_cluster["default"].secret_arn}:username::"
          },
          {
            name      = "DB_PASSWORD"
            valueFrom = "${module.rds_cluster["default"].secret_arn}:password::"
          },
          {
            name      = "DB_HOST"
            valueFrom = "${module.rds_cluster["default"].secret_arn}:host::"
          },
          {
            name      = "DB_PORT"
            valueFrom = "${module.rds_cluster["default"].secret_arn}:port::"
          },
          {
            name      = "DB_NAME"
            valueFrom = "${module.rds_cluster["default"].secret_arn}:dbInstanceIdentifier::"
          }
        ]
      }
    }
    worker = {
      host_header     = null
      external_access = false
      cdn_type        = null
      backend_type    = "ecs"
      security_groups = [module.app-productstack.productstack-sg-ids["compute-api"].id]
      alb             = null
      ecs = {
        capacity_provider_strategy = [
          {
            capacity_provider = "FARGATE_SPOT",
            weight            = 100
          }
        ]
        image_url      = "${local.ecr_repos["api"].repository_url}:dev-latest"
        cpu            = 256
        memory         = 512
        desired_count  = 1
        container_name = "main"
        container_port = 3000
        min_scale      = 1
        max_scale      = 10
        target_memory  = 80
        target_cpu     = 45
        command        = ["bundle", "exec", "rails", "jobs:work"]

        mount_points     = []
        file_system_id   = null
        volume_directory = null
        volume_name      = null

        environment_variables = [
          {
            name  = "WEB_HOST"
            value = local.api_dns
          },
          {
            name  = "BACKEND_DOMAIN"
            value = local.api_dns
          },
          {
            name  = "SES_HOST"
            value = "email-smtp.us-east-1.amazonaws.com"
          },
          {
            name  = "APP_ENV"
            value = "app"
          },
          {
            name  = "FREEMIUM_COURSES_LIMIT"
            value = "3"
          },
          {
            name  = "FREEMIUM_STUDENTS_LIMIT"
            value = "20"
          },
          {
            name  = "FREEMIUM_MISSIONS_LIMIT"
            value = "3"
          },
          {
            name  = "FREEMIUM_COURSE_BADGES_LIMIT"
            value = "10"
          },
          {
            name  = "FREEMIUM_LEVELS_LIMIT"
            value = "5"
          },
          {
            name  = "FREEMIUM_BEHAVIORS_LIMIT"
            value = "6"
          },
          {
            name  = "PREMIUM_B2C_STUDENTS_LIMIT",
            value = "150"
          },
          {
            name  = "CULQI_URI",
            value = "https://api.culqi.com/v2/"
          },
          {
            name  = "SWAGGER_USER_NAME",
            value = "swagger_user"
          },
          {
            name  = "SWAGGER_PASSWORD",
            value = "AiMJYoiIYT"
          },
          {
            name  = "SCHEDULER_LAMBDA_ARN"
            value = module.docker-lambdas["python-main"].arn
          },
          {
            name  = "SCHEDULER_IAM_ROLE_ARN"
            value = module.docker-lambdas-scheduling-permissions["python-main"].role_arn
          },
          {
            name  = "CONFIRM_SUCCESS_URL"
            value = "https://app.plataformajuried.com/confirmation"
          }
        ]
        secrets = [
          {
            name      = "SECRET_KEY_BASE"
            valueFrom = "${local.juried_api_secret}:SECRET_KEY_BASE::"
          },
          {
            name      = "SES_SMTP_USERNAME"
            valueFrom = "${local.juried_api_secret}:SES_SMTP_USERNAME::"
          },
          {
            name      = "SES_SMTP_PASSWORD"
            valueFrom = "${local.juried_api_secret}:SES_SMTP_PASSWORD::"
          },
          {
            name      = "SENTRY_DNS"
            valueFrom = "${local.juried_api_secret}:SENTRY_DNS::"
          },
          {
            name      = "S3_BUCKET"
            valueFrom = "${local.juried_api_secret}:S3_BUCKET::"
          },
          {
            name      = "CULQI_PRIVATE_KEY"
            valueFrom = "${local.juried_api_secret}:CULQI_PRIVATE_KEY::"
          },
          {
            name      = "WEBHOOK_PERMITTED_KEY"
            valueFrom = "${local.juried_api_secret}:WEBHOOK_PERMITTED_KEY::"
          },
          {
            name      = "SCHEDULER_PERMITTED_KEYS"
            valueFrom = "${local.juried_api_secret}:SCHEDULER_PERMITTED_KEYS::"
          },
          {
            name      = "DB_USERNAME"
            valueFrom = "${module.rds_cluster["default"].secret_arn}:username::"
          },
          {
            name      = "DB_PASSWORD"
            valueFrom = "${module.rds_cluster["default"].secret_arn}:password::"
          },
          {
            name      = "DB_HOST"
            valueFrom = "${module.rds_cluster["default"].secret_arn}:host::"
          },
          {
            name      = "DB_PORT"
            valueFrom = "${module.rds_cluster["default"].secret_arn}:port::"
          },
          {
            name      = "DB_NAME"
            valueFrom = "${module.rds_cluster["default"].secret_arn}:dbInstanceIdentifier::"
          }
        ]
      }
    }
    data-visualization = {
      host_header     = local.dv_dns
      external_access = true
      cdn_type        = "non-cached"
      backend_type    = "ecs"
      security_groups = [module.app-productstack.productstack-sg-ids["compute-data-visualization"].id]
      alb = {
        listener_arn        = module.albs["public"].https_listener_arn
        health_check_path   = "/login"
        health_check_status = 308
      }
      ecs = {
        capacity_provider_strategy = [
          {
            capacity_provider = "FARGATE_SPOT",
            weight            = 100
          }
        ]
        image_url      = "apache/superset"
        cpu            = 256
        memory         = 512
        desired_count  = 1
        container_name = "main"
        container_port = 8088
        min_scale      = 1
        max_scale      = 1
        target_memory  = 80
        target_cpu     = 45
        command        = ["/usr/bin/run-server.sh"]

        mount_points = [
          {
            containerPath = "/app/superset_home"
            sourceVolume  = "efs-data-visualization"
          }
        ]
        file_system_id   = module.efs["data-visualization"].id
        volume_directory = "/data"
        volume_name      = "efs-data-visualization"

        environment_variables = [
          {
            name  = "SUPERSET_SECRET_KEY"
            value = "FFjKQRzV1WTMggEv6dfP8ktrYO4Aty508DuNr1Awuf5myC1gBC"
          }
        ]
        secrets = []
      }
    }
  }

  ssm_parameters = {
    API_IMAGE_REPO_NAME        = local.ecr_repos["api"].repository_url
    API_ECS_TASK_DEFINITION    = module.ecs_task_definitions["api"].family
    WORKER_ECS_TASK_DEFINITION = module.ecs_task_definitions["worker"].family
    API_ECS_SERVICE            = module.ecs_services["api"].name
    WORKER_ECS_SERVICE         = module.ecs_services_not_lb["worker"].name
    API_ECS_CLUSTER            = module.ecs_cluster.name

    ECS_SUBNET_ID                 = module.vpc.private_subnets[0]
    ECS_SERVICE_SECURITY_GROUP_ID = module.app-productstack.productstack-sg-ids["compute-api"].id
    FRONTEND_BUCKET_NAME          = module.buckets["frontend"].id
    FRONTEND_DISTRIBUTION_ID      = module.s3_cloudfront["frontend"].id

    REACT_APP_BASE_CULQI_URL   = "https://checkout.culqi.com"
    REACT_APP_CULQI_URL        = "https://checkout.culqi.com/js/v4"
    REACT_APP_CULQI_PUBLIC_KEY = "pk_live_4807928b78c0664d"
    REACT_APP_PUBLIC_URL       = "https://public.${local.root_dns}"

    LAMBDA_IMAGE_REPO_NAME = local.ecr_repos["lambdas"].repository_url
  }

  efs_instances = {
    data-visualization = {
      subnet_id       = module.vpc.private_subnets[0]
      security_groups = [module.app-productstack.productstack-sg-ids["storage-data-visualization-efs"].id]
    }
  }

  docker_lambdas = {
    python-main = {
      can_be_scheduled   = true
      security_group_ids = null
      subnet_ids         = null
      image_uri          = "${local.ecr_repos["lambdas"].repository_url}:latest"
      command            = ["app.handler"]
      variables = {
        DNS_URL      = local.api_dns
        TOKEN_HEADER = jsondecode(data.aws_secretsmanager_secret_version.juried-api.secret_string)["SCHEDULER_PERMITTED_KEYS"]
      }
    }
  }
}