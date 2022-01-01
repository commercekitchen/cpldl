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
