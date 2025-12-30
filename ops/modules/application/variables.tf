variable "vpc_id" {}
variable "region" {}
variable "ecs_cluster_id" {}
variable "ecs_cluster_name" {}
variable "public_subnet_ids" {}
variable "db_access_security_group_id" {}
variable "redis_access_security_group_id" {}
variable "project_name" {}
variable "environment_name" {}
variable "db_host" {}
variable "rails_master_key_arn" {}
variable "instance_type" {}
variable "lb_target_group_arn" {}
variable "max_instance_count" { default = 2 }
variable "desired_task_count" {}
variable "min_task_count" { default = 1 }
variable "max_task_count" { default = 2 }
variable "s3_bucket_arns" {}
variable "service_memory" { default = 512 }
variable "service_cpu" { default = 512 }
variable "task_execution_role_arn" {
  type        = string
  description = "ARN of the ECS task execution role"
}
variable "image" {
  type = string
  description = "Default image URI for the application container (overridden by CodePipeline deployments)."
} 
variable "load_balancer_sg_id" {
  type = string
  description = "ID of load balancer security group"
}
