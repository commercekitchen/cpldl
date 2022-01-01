variable "project_name" {}
variable "environment_name" {}
variable "region" {}

variable "vpc_cidr_blocks" {
  default = "10.0.0.0/16"
}

variable "public_subnets_cidr" {}
variable "private_subnets_cidr" {}
variable "availability_zones" {}
