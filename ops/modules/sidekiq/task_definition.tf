resource "aws_ecs_task_definition" "sidekiq" {
  family                   = "${var.project_name}-sidekiq-task-${var.environment_name}"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  cpu                      = var.task_cpu
  execution_role_arn       = var.task_execution_role_arn

  container_definitions = jsonencode([
    {
      name              = "sidekiq"
      image             = var.image
      cpu               = var.task_cpu
      memoryReservation = var.memory_reservation
      essential         = true

      command = ["bundle", "exec", "sidekiq", "-C", "config/sidekiq.yml"]

      environment = [
        { name = "SKIP_ASSETS",         value = "true" }, // Don't precompile assets for sidekiq
        { name = "RAILS_ENV",           value = var.environment_name },
        { name = "RAILS_LOG_TO_STDOUT", value = "true" }
      ]

      secrets = [
        {
          name      = "RAILS_MASTER_KEY",
          valueFrom = var.rails_master_key_arn
        }
      ]

      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = aws_cloudwatch_log_group.sidekiq_log_group.name,
          awslogs-region        = var.region,
          awslogs-stream-prefix = "sidekiq"
        }
      }
    }
  ])
}