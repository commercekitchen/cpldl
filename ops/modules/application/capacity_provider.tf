resource "aws_ecs_capacity_provider" "app_capacity_provider" {
  name = "${var.project_name}-${var.environment_name}-app-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.asg.arn

    managed_termination_protection = "DISABLED"

    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 2
      instance_warmup_period    = 300
    }
  }
}
