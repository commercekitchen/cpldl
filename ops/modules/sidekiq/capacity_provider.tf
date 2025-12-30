resource "aws_ecs_capacity_provider" "sidekiq_capacity_provider" {
  name = "${var.project_name}-${var.environment_name}-sidekiq-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.sidekiq_asg.arn
    
    managed_termination_protection = "DISABLED"
    
    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 80
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 1
      instance_warmup_period    = 300
    }
  }
}