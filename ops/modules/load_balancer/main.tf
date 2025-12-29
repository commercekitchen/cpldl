resource "aws_lb" "load_balancer" {
  name            = "${var.project_name}-${var.environment_name}-lb"
  security_groups = [aws_security_group.load_balancer_sg.id]
  subnets         = var.public_subnet_ids

  enable_deletion_protection = true
}

resource "aws_lb_target_group" "load_balancer_tg" {
  name        = "${var.project_name}-${var.environment_name}-lb-tg"
  target_type = "instance"
  port        = 80
  protocol    = "HTTP"
  vpc_id      = var.vpc_id

  health_check {
    protocol            = "HTTP"
    path                = "/"
    port                = "traffic-port"
    healthy_threshold   = 2
    unhealthy_threshold = 5
    timeout             = 10
    interval            = 30
    matcher             = "200-499"
  }
}

resource "aws_lb_listener" "http_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "https_listener" {
  load_balancer_arn = aws_lb.load_balancer.arn
  port              = 443
  protocol          = "HTTPS"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.load_balancer_tg.arn
  }
}

