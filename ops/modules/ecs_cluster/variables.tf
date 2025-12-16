variable "project_name" {
  description = "The name of the project."
  type        = string
}

variable "environment_name" {
  description = "The name of the environment."
  type        = string
}

variable "region" {
  description = "The AWS region where the infrastructure is deployed."
  type        = string
}

variable "insights_enabled" {
  description = "Enable or disable container insights."
  type        = bool
  default     = false
}

variable "rails_master_key_arn" {
  type        = string
  description = "Secrets Manager ARN for Rails master key"
}

variable "app_capacity_provider_name" {
  type = string
  description = "Name of the app capacity provider"
}

variable "sidekiq_capacity_provider_name" {
  type = string
  description = "Name of the sidekiq capacity provider"
}