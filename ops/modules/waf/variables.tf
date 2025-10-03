variable "project_name" {
  description = "Name of the project"
  type        = string
}

variable "environment_name" {
  description = "Environment name"
  type        = string
}

variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-west-2"
}

variable "web_acl_name" {
  description = "Name for the WAF WebACL"
  type        = string
}

variable "alb_arn" {
  description = "ARN of the Application Load Balancer"
  type        = string
}

variable "enable_shield" {
  description = "Enable AWS Shield Advanced for DDoS protection"
  type        = bool
  default     = false
}

variable "rate_limiter_threshold" {
  description = "Threshold for rate limiting (requests per 5 minutes per IP)"
  type        = number
  default     = 1000
}