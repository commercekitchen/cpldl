variable "project_name" {}
variable "environment_name" {}
variable "node_type" { default = "cache.t3.micro" }
variable "cache_node_type" { default = "cache.t4g.micro" }
variable "subnet_ids" {}
variable "vpc_id" {}

variable "high_availability" {
  description = "Higher availability cluster for production applications"
  type        = bool
  default     = false
}

variable "redis_alarm_emails" {
  description = "List of email addresses to subscribe to Redis SNS alarm topic"
  type        = list(string)
  default     = []
}
