resource "aws_security_group" "db_access_sg" {
  name        = "${var.project_name}-${var.environment_name}-database-access-sg"
  description = "Database access security group"
  vpc_id      = var.vpc_id
}

resource "aws_security_group" "db_sg" {
  name   = "${var.project_name}-${var.environment_name}-database-sg"
  vpc_id = var.vpc_id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  ingress {
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.db_access_sg.id]
    description     = "Access to RDS database"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Outbound access for RDS"
  }
}
