resource "aws_security_group" "application_sg" {
  name        = "application-sg"
  description = "Allow access to rails application"
  vpc_id      = var.vpc_id

  // Ping port
  ingress {
    from_port   = 8
    to_port     = 0
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic from application"
  }
}

resource "aws_security_group_rule" "alb_to_ecs_ephemeral" {
  type                     = "ingress"
  security_group_id        = aws_security_group.application_sg.id
  source_security_group_id = var.load_balancer_sg_id
  protocol                 = "tcp"
  from_port                = 32768
  to_port                  = 65535
  description              = "ALB to ECS tasks on dynamic host ports"
}
