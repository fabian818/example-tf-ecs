module "app-productstack" {
  source           = "../modules/productstack"
  additional_tags  = local.product_tags
  resource_prefix  = local.resource_prefix
  component_prefix = "app"

  vpc_id = module.vpc.vpc_id
  components = {
    alb-public = {
      name = "ALB public"
      ingress = [
        {
          source   = "cidr-0.0.0.0/0"
          from     = 443
          to       = 443
          protocol = "tcp"
        },
        {
          source   = "cidr-0.0.0.0/0"
          from     = 80
          to       = 80
          protocol = "tcp"
        }
      ]
      egress = [
        {
          source   = "cidr-0.0.0.0/0"
          from     = 0
          to       = 65535
          protocol = "tcp"
        },
        {
          source   = "compute-api"
          from     = 3000
          to       = 3000
          protocol = "tcp"
        }
      ]
    }
    compute-api = {
      name = "Compute Api"

      ingress = [
        {
          source   = "alb-public"
          from     = 3000
          to       = 3000
          protocol = "tcp"
        },
        {
          source   = "compute-bastion"
          from     = 3000
          to       = 3000
          protocol = "tcp"
        },
        {
          source   = "cidr-0.0.0.0/0"
          from     = 443
          to       = 443
          protocol = "tcp"
        }
      ]
      egress = [
        {
          source   = "storage-default-rds"
          from     = 5432
          to       = 5432
          protocol = "tcp"
        },
        {
          source   = "alb-public"
          from     = 0
          to       = 65535
          protocol = "tcp"
        },
        {
          source   = "cidr-0.0.0.0/0"
          from     = 443
          to       = 443
          protocol = "tcp"
        },
        {
          source   = "cidr-0.0.0.0/0"
          from     = 587
          to       = 587
          protocol = "tcp"
        }
      ]
    }
    compute-bastion = {
      name = "Compute Bastion"
      ingress = [
        {
          source   = "cidr-0.0.0.0/0"
          from     = 22
          to       = 22
          protocol = "tcp"
        }
      ]
      egress = [
        {
          source   = "storage-default-rds"
          from     = 5432
          to       = 5432
          protocol = "tcp"
        },
        {
          source   = "cidr-0.0.0.0/0"
          from     = 0
          to       = 65535
          protocol = "tcp"
        },
      ]
    }
    storage-default-rds = {
      name = "Storage Default RDS"
      ingress = [
        {
          source   = "compute-api"
          from     = 5432
          to       = 5432
          protocol = "tcp"
        },
        {
          source   = "compute-bastion"
          from     = 5432
          to       = 5432
          protocol = "tcp"
        }
      ]
      egress = [
        {
          source   = "compute-api"
          from     = 5432
          to       = 5432
          protocol = "tcp"
        },
        {
          source   = "compute-bastion"
          from     = 5432
          to       = 5432
          protocol = "tcp"
        }
      ]
    }
  }

  depends_on = [
    module.vpc
  ]
}
