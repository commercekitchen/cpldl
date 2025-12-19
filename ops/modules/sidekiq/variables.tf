variable "project_name" {}
variable "environment_name" {}
variable "region" {}
variable "vpc_id" {}
variable "public_subnet_ids" {
  description = "List of public subnet IDs for the ECS cluster"
  type        = list(string)
}

variable "ecr_repository_url" {}
variable "ecr_project_uri" {}
variable "ecs_cluster_id" {}
variable "ecs_cluster_name" {}
variable "image" {}
variable "log_retention_days" { default = 7 }
variable "instance_type" {}
variable "desired_instance_count" { default = 1 }
variable "min_task_count" { default = 1 }
variable "max_task_count" { default = 2 }
variable "task_cpu" { default = 256 }
variable "memory_reservation" { default = 1700 }

variable "db_access_security_group_id" {}
variable "redis_access_security_group_id" {}

variable "redis_host" {}
variable "redis_port" { default = 6379 }
variable "db_host" {}

variable "rails_master_key_arn" {}

variable "task_execution_role_arn" {
  type        = string
  description = "ARN of the ECS task execution role"
}