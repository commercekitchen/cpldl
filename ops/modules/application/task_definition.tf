resource "aws_ecs_task_definition" "app_service" {
  family                   = "${var.project_name}-app-task-definition-${var.environment_name}"
  requires_compatibilities = ["EC2"]
  network_mode             = "bridge"
  memory                   = var.service_memory
  cpu                      = var.service_cpu
  execution_role_arn       = var.task_execution_role_arn

  container_definitions = jsonencode([
    {
      name      = "application",
      image     = var.image,
      essential = true,
      portMappings = [
        {
          hostPort      = 0,
          protocol      = "tcp",
          containerPort = 3000
        }
      ],
      command = ["bundle", "exec", "puma", "-C", "config/puma.rb"],
      environment = [
        {
          name = "SKIP_MIGRATIONS",
          value = "false"
        }, // Run migrations on app deployment
        {
          name  = "POSTGRES_HOST",
          value = "${var.db_host}"
        },
        {
          name  = "RAILS_ENV",
          value = "${var.environment_name}"
        },
        {
          name  = "RAILS_MAX_THREADS",
          value = "5"
        },
        {
          name  = "RAILS_LOG_TO_STDOUT",
          value = "true"
        },
        {
          name  = "ROLLBAR_ENV",
          value = "${var.environment_name}"
        }
      ],
      secrets = [
        {
          # single-value secret (string)
          name      = "RAILS_MASTER_KEY"
          valueFrom = var.rails_master_key_arn
        },
      ],
      logConfiguration = {
        logDriver = "awslogs",
        options = {
          awslogs-group         = "${aws_cloudwatch_log_group.instance.name}",
          awslogs-region        = "${var.region}",
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
}
