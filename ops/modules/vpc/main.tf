resource "aws_vpc" "vpc" {
  cidr_block           = var.vpc_cidr_blocks
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name} VPC (${var.environment_name})"
  }
}

/* Internet Gatway for public subnet */
resource "aws_internet_gateway" "gateway" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "${var.project_name} Gateway (${var.environment_name})"
  }
}