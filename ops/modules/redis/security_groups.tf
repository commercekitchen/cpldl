resource "aws_security_group" "redis_access_sg" {
  name        = "${var.project_name}-${var.environment_name}-redis-access-sg"
  description = "Redis access security group"
  vpc_id      = var.vpc_id
}

resource "aws_security_group" "redis_sg" {
  name   = "${var.project_name}-${var.environment_name}-redis-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port       = 6379
    to_port         = 6379
    protocol        = "tcp"
    security_groups = [aws_security_group.redis_access_sg.id]
    description     = "Access to Elasticache Redis"
  }
}
