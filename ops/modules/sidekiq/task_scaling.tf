resource "aws_appautoscaling_target" "sidekiq_scaling_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.sidekiq.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.min_instance_count
  max_capacity       = var.max_instance_count
}

resource "aws_appautoscaling_policy" "sidekiq_cpu_policy" {
  name               = "${var.project_name}-${var.environment_name}-sidekiq-cpu-scaling"
  service_namespace  = aws_appautoscaling_target.sidekiq_scaling_target.service_namespace
  resource_id        = aws_appautoscaling_target.sidekiq_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.sidekiq_scaling_target.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 60.0
    scale_in_cooldown  = 100
    scale_out_cooldown = 60
  }
}
