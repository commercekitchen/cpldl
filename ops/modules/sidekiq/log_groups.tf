resource "aws_cloudwatch_log_group" "sidekiq_log_group" {
  name              = "/ecs/sidekiq-${var.environment_name}"
  retention_in_days = var.log_retention_days
}
