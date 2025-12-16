output "redis_access_security_group_id" { value = aws_security_group.redis_access_sg.id }
output "redis_endpoint" {
  value = aws_elasticache_replication_group.redis.primary_endpoint_address
}
