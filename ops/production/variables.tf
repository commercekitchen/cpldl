variable "project_name" { default = "dl-training" }
variable "environment_name" { default = "production" }
variable "region" { default = "us-west-2" }
variable "database_name" { default = "railsapp_production" }

variable "db_username" {
  description = "Database administrator username"
  type        = string
  sensitive   = true
}

variable "db_password" {
  description = "Database administrator password"
  type        = string
  sensitive   = true
}

variable "rails_master_key" {
  description = "Master encryption key for encrypted Rails credentials"
  type        = string
  sensitive   = true
}

variable "github_oauth_token" {
  description = "OAuth token for GitHub integration"
  type        = string
  sensitive   = true
}

variable "docker_username" {}
variable "docker_password" {
  description = "Docker account password"
  type        = string
  sensitive   = true
}
