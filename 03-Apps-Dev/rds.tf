module "rds_kms_key" {
  source = "../modules/kms_key"

  resource_prefix  = local.resource_prefix
  additional_tags  = local.product_tags
  component_prefix = "rds"
}

module "rds_cluster" {
  source = "../modules/rds"

  for_each = local.rds

  resource_prefix  = local.resource_prefix
  additional_tags  = local.product_tags
  component_prefix = each.key

  engine                  = each.value.engine
  engine_version          = each.value.engine_version
  subnet_ids              = each.value.subnet_ids
  vpc_security_group_ids  = each.value.vpc_security_group_ids
  database_name           = each.value.database_name
  master_username         = each.value.master_username
  backup_retention_period = each.value.backup_retention_period
  kms_key_id              = each.value.kms_key_id
  instance_class          = each.value.instance_class
  allocated_storage       = each.value.allocated_storage
  deletion_protection     = each.value.deletion_protection
  skip_final_snapshot     = each.value.skip_final_snapshot
}