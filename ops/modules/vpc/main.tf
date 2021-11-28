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

/* Elastic IP for NAT */
resource "aws_eip" "nat_eip" {
  vpc = true
  depends_on = [
    aws_internet_gateway.gateway
  ]

  tags = {
    Name = "${var.project_name} EIP (${var.environment_name})"
  }
}

/* NAT */
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = element(aws_subnet.public_subnet.*.id, 0)
  depends_on = [
    aws_internet_gateway.gateway
  ]

  tags = {
    Name = "${var.project_name} NAT ${var.environment_name}"
  }
}
