resource "aws_security_group" "sidekiq_sg" {
  name        = "${var.project_name}-${var.environment_name}-sidekiq-sg"
  description = "Security group for Sidekiq ECS tasks"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"] # or restrict to only internal services if preferred
    description = "Allow all outbound"
  }

  tags = {
    Name        = "${var.project_name}-${var.environment_name}-sidekiq-sg"
    Environment = var.environment_name
  }
}