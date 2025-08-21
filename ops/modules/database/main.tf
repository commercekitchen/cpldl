resource "aws_db_subnet_group" "application" {
  name       = "${var.project_name}-${var.environment_name}-db-subnet-group"
  subnet_ids = var.private_subnet_ids

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_db_instance" "app_db" {
  snapshot_identifier                   = var.db_snapshot_name
  engine_version                        = "13.20"
  allow_major_version_upgrade           = true
  instance_class                        = var.instance_size
  monitoring_interval                   = var.enable_monitoring ? var.monitoring_interval : 0
  monitoring_role_arn                   = var.enable_monitoring ? aws_iam_role.rds_enhanced_monitoring[0].arn : null
  vpc_security_group_ids                = [aws_security_group.db_sg.id]
  availability_zone                     = var.multi_az ? null : "${var.region}a"
  multi_az                              = var.multi_az
  db_subnet_group_name                  = aws_db_subnet_group.application.name
  identifier                            = "${var.project_name}-${var.environment_name}"
  skip_final_snapshot                   = var.skip_final_snapshot
  final_snapshot_identifier             = "${var.project_name}-${var.environment_name}-final-snapshot"
  backup_retention_period               = var.backup_retention
  enabled_cloudwatch_logs_exports       = ["postgresql", "upgrade"]
  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  copy_tags_to_snapshot                 = true
  deletion_protection                   = true

  lifecycle {
    prevent_destroy = true
  }
}

