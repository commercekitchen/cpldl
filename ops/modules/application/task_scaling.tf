resource "aws_appautoscaling_target" "app_scaling_target" {
  service_namespace  = "ecs"
  resource_id        = "service/${var.ecs_cluster_name}/${aws_ecs_service.ecs_service.name}"
  scalable_dimension = "ecs:service:DesiredCount"
  min_capacity       = var.min_task_count
  max_capacity       = var.max_task_count
}

resource "aws_appautoscaling_policy" "app_cpu_policy" {
  name               = "${var.project_name}-${var.environment_name}-app-cpu-scaling"
  service_namespace  = aws_appautoscaling_target.app_scaling_target.service_namespace
  resource_id        = aws_appautoscaling_target.app_scaling_target.resource_id
  scalable_dimension = aws_appautoscaling_target.app_scaling_target.scalable_dimension
  policy_type        = "TargetTrackingScaling"

  target_tracking_scaling_policy_configuration {
    predefined_metric_specification {
      predefined_metric_type = "ECSServiceAverageCPUUtilization"
    }

    target_value       = 50.0   # web: aim lower than sidekiq for headroom
    scale_in_cooldown  = 120
    scale_out_cooldown = 60
  }
}
