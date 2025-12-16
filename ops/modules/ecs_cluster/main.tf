resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project_name}-cluster-${var.environment_name}"

  setting {
    name  = "containerInsights"
    value = var.insights_enabled ? "enabled" : "disabled"
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment_name
  }
}
