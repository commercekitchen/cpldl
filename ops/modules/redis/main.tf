# Parameter group for Sidekiq Redis (noeviction)
resource "aws_elasticache_parameter_group" "sidekiq_params" {
  name   = "${var.project_name}-${var.environment_name}-sidekiq-params"
  family = "redis7"

  parameter {
    name  = "maxmemory-policy"
    value = "noeviction"
  }
}

# Sidekiq Redis
resource "aws_elasticache_replication_group" "redis" {
  description                   = "Redis replication group for Sidekiq"
  replication_group_id          = "${var.project_name}-${var.environment_name}-redis"
  engine                        = "redis"
  engine_version                = "7.1"
  node_type                     = var.node_type
  port                          = 6379
  subnet_group_name             = aws_elasticache_subnet_group.redis.name
  security_group_ids            = [aws_security_group.redis_sg.id]
  parameter_group_name          = aws_elasticache_parameter_group.sidekiq_params.name
  at_rest_encryption_enabled    = true
  transit_encryption_enabled    = false
  num_node_groups               = 1
  auto_minor_version_upgrade    = false

  automatic_failover_enabled    = var.high_availability
  replicas_per_node_group       = var.high_availability ? 1 : 0

  snapshot_retention_limit      = var.high_availability ? 7 : 3
  snapshot_window               = "05:00-06:00" # UTC time window for backup (11pm-12am MST)

  tags = {
    Name        = "${var.project_name}-${var.environment_name}-redis"
    Environment = var.environment_name
  }
}

resource "aws_elasticache_subnet_group" "redis" {
  name       = "${var.project_name}-${var.environment_name}-redis-subnet-group"
  subnet_ids = var.subnet_ids
}

