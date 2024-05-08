variable "vpc_id" {}
variable "region" {}
variable "public_subnet_ids" {}
variable "default_security_group_id" {}
variable "db_access_security_group_id" {}
variable "project_name" {}
variable "environment_name" {}
variable "db_host" {}
variable "rails_master_key" {}
variable "db_username" {}
variable "db_password" {}
variable "instance_type" {}
variable "lb_target_group_arn" {}
variable "ssh_key_name" {}
variable "desired_instance_count" {}
variable "s3_bucket_arns" {}
variable "service_memory" { default = 512 }
variable "service_cpu" { default = 512 }
