resource "aws_cloudwatch_log_group" "instance" {
  name = "${var.project_name}-log-group-${var.environment_name}"
  retention_in_days = var.log_retention_days
}
