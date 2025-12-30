resource "aws_ecs_service" "ecs_service" {
  name                              = "${var.project_name}-${var.environment_name}-service"
  cluster                           = var.ecs_cluster_id
  task_definition                   = aws_ecs_task_definition.app_service.arn
  desired_count                     = var.desired_task_count
  health_check_grace_period_seconds = 60

  force_new_deployment = true
  capacity_provider_strategy {
    capacity_provider = aws_ecs_capacity_provider.app_capacity_provider.name
    weight            = 1
  }

  load_balancer {
    target_group_arn = var.lb_target_group_arn
    container_name   = "application"
    container_port   = 3000
  }

  placement_constraints {
    type       = "memberOf"
    expression = "attribute:ecs.availability-zone in [${var.region}a, ${var.region}b]"
  }

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  lifecycle {
    ignore_changes = [
      task_definition, # deployment pipeline owns releases
    ]
  }
}

data "aws_ssm_parameter" "web_server_ami" {
  name = "/aws/service/ecs/optimized-ami/amazon-linux-2/recommended/image_id"
}

resource "aws_key_pair" "developer_encryption_key" {
  key_name   = "developer-encryption-key-${var.project_name}-${var.environment_name}"
  public_key = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHhSagwW5vT7J/uu94PBAHkTXivaSxYFx2vBeMvzIcLq dl-learners-staging"
}

resource "aws_launch_template" "instance" {
  name_prefix   = "${var.project_name}-lt-"
  image_id      = data.aws_ssm_parameter.web_server_ami.value
  instance_type = var.instance_type
  key_name      = aws_key_pair.developer_encryption_key.key_name

  iam_instance_profile {
    name = aws_iam_instance_profile.ecs_instance.name
  }


  vpc_security_group_ids = [
    aws_security_group.application_sg.id,
    var.db_access_security_group_id,
    var.redis_access_security_group_id
  ]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    set -euxo pipefail

    mkdir -p /etc/ecs
    cat >/etc/ecs/ecs.config <<CONFIG
  ECS_CLUSTER=${var.ecs_cluster_name}
  CONFIG
  EOF
  )


  tag_specifications {
    resource_type = "instance"

    tags = {
      Name        = "${var.project_name} App Instance ${var.environment_name}"
      ecs_cluster = var.ecs_cluster_name
    }
  }
}
