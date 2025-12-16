variable "project_name" { default = "dl-learners" }
variable "environment_name" { default = "staging" }
variable "region" { default = "us-west-2" }
variable "database_name" { default = "railsapp_staging" }

variable "certificate_arn" {
  description = "SSL Certificate resource ARN"
  type        = string
  sensitive   = true
}

variable "alarm_notification_emails" {
  description = "List of email addresses to subscribe to SNS alarm topics"
  type        = list(string)
  default     = ["tom@emberthread.co"]
}
