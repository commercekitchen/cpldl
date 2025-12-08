data "aws_ssm_parameter" "sidekiq_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_launch_template" "instance" {
  name_prefix   = "${var.project_name}-lt-"
  instance_type = var.instance_type
  image_id      = data.aws_ssm_parameter.sidekiq_ami.value

  monitoring {
    enabled = true
  }

  iam_instance_profile {
    name = aws_iam_instance_profile.sidekiq_instance_profile.name
  }

  vpc_security_group_ids = [
    aws_security_group.sidekiq_sg.id,
    var.db_access_security_group_id,
    var.redis_access_security_group_id
  ]

  # Required: base64-encoded user_data for launch templates
  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo ECS_CLUSTER=${var.ecs_cluster_name} >> /etc/ecs/ecs.config
  EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name        = "${var.project_name}-${var.environment_name}-sidekiq"
      Environment = var.environment_name
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_ecs_service" "sidekiq" {
  name                     = "${var.project_name}-${var.environment_name}-sidekiq-service"
  cluster                  = var.ecs_cluster_id
  task_definition          = aws_ecs_task_definition.sidekiq.arn
  desired_count            = var.desired_instance_count

  enable_ecs_managed_tags  = true
  propagate_tags           = "SERVICE"

  deployment_minimum_healthy_percent = 50
  deployment_maximum_percent         = 200 # Allow double capacity during deployment/load

  wait_for_steady_state = false # Don't fail terraform apply if this doesn't start

  ordered_placement_strategy {
    type  = "binpack"
    field = "memory"
  }

  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.sidekiq_capacity_provider.name
    weight            = 1
    base              = 0
  }

  deployment_circuit_breaker {
    enable   = true
    rollback = true
  }

  lifecycle {
    # Don't overwrite latest task definition revision
    # WARNING: changing the task_definition will case ECS to use the latest
    # sidekiq image, which is usually the one deployed to staging (latest tag)
    # Sometimes, we want to update the task_definition, but it should be
    # done with care to avoid releasing untested code to production sidekiq
    # ignore_changes = [task_definition]
  }

  tags = {
    Project     = var.project_name
    Environment = var.environment_name
  }
}