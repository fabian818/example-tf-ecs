resource "aws_db_subnet_group" "default" {
  name       = "${local.prefix}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = merge(var.additional_tags, {
    Name = "${local.prefix}-subnet-group"
  })
}

resource "random_password" "password" {
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_rds_cluster" "default" {
  deletion_protection = var.deletion_protection
  skip_final_snapshot = var.skip_final_snapshot

  cluster_identifier = "${local.prefix}-rds-instance"
  database_name      = var.database_name
  engine             = var.engine
  engine_version     = var.engine_version
  engine_mode        = "serverless"
  master_username    = var.master_username

  apply_immediately = !var.deletion_protection
  master_password   = random_password.password.result

  backup_retention_period = var.backup_retention_period
  storage_encrypted       = true
  kms_key_id              = var.kms_key_id
  vpc_security_group_ids  = var.vpc_security_group_ids
  db_subnet_group_name    = aws_db_subnet_group.default.name


  scaling_configuration {
    auto_pause               = true
    max_capacity             = 2
    min_capacity             = 2
    seconds_until_auto_pause = 600
    timeout_action           = "ForceApplyCapacityChange"
  }

  tags = merge(var.additional_tags, {
    Name = "${local.prefix}-rds-instance"
  })
}


resource "aws_secretsmanager_secret" "default" {
  name = "${local.prefix}-secret-${local.timestamp_sanitized}"

  lifecycle {
    ignore_changes = [
      name
    ]
  }
}

resource "aws_secretsmanager_secret_version" "default" {
  secret_id = aws_secretsmanager_secret.default.id
  secret_string = jsonencode({
    username             = var.master_username
    dbInstanceIdentifier = var.database_name
    password             = random_password.password.result
    port                 = 5432
    host                 = aws_rds_cluster.default.endpoint
    engine               = "postgres"
  })
}
