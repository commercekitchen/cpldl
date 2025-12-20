resource "aws_security_group" "application_sg" {
  name        = "application-sg"
  description = "Allow access to rails application"
  vpc_id      = var.vpc_id
}

resource "aws_security_group_rule" "app_egress_all" {
  type              = "egress"
  security_group_id = aws_security_group.application_sg.id
  protocol          = "-1"
  from_port         = 0
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "app_icmp" {
  type              = "ingress"
  security_group_id = aws_security_group.application_sg.id
  protocol          = "icmp"
  from_port         = 8
  to_port           = 0
  cidr_blocks       = ["0.0.0.0/0"]
}

resource "aws_security_group_rule" "alb_to_ecs_ephemeral" {
  type                     = "ingress"
  security_group_id        = aws_security_group.application_sg.id
  source_security_group_id = var.load_balancer_sg_id
  protocol                 = "tcp"
  from_port                = 32768
  to_port                  = 65535
}
