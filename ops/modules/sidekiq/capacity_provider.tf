resource "aws_ecs_capacity_provider" "sidekiq_capacity_provider" {
  name = "${var.project_name}-${var.environment_name}-sidekiq-capacity-provider"

  auto_scaling_group_provider {
    auto_scaling_group_arn = aws_autoscaling_group.sidekiq_asg.arn
    
    managed_termination_protection = "DISABLED"
    
    managed_scaling {
      status                    = "ENABLED"
      target_capacity           = 100
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 1
      instance_warmup_period    = 300
    }
  }
}

# Associate capacity provider with cluster
resource "aws_ecs_cluster_capacity_providers" "sidekiq_cluster_capacity_providers" {
  cluster_name = var.ecs_cluster_name

  capacity_providers = [aws_ecs_capacity_provider.sidekiq_capacity_provider.name]

  default_capacity_provider_strategy {
    base              = 0
    weight            = 1
    capacity_provider = aws_ecs_capacity_provider.sidekiq_capacity_provider.name
  }
}