resource "aws_ecs_cluster" "ecs_cluster" {
  name = "${var.project_name}-cluster-${var.environment_name}"
}

resource "aws_ecs_service" "ecs_service" {
  name                              = "${var.project_name}-${var.environment_name}-service"
  cluster                           = aws_ecs_cluster.ecs_cluster.id
  task_definition                   = aws_ecs_task_definition.app_service.arn
  desired_count                     = var.desired_instance_count
  iam_role                          = aws_iam_role.instance.name
  health_check_grace_period_seconds = 60

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
    type  = "spread"
    field = "instanceId"
  }
}

data "aws_ami" "ecs_ami" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn-ami-*-amazon-ecs-optimized"]
  }
}

resource "aws_key_pair" "app_instance_key" {
  key_name   = "app-instance-key-${var.project_name}-${var.environment_name}"
  public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCc4aJ32ODM+cgouELWfAA/AIVwiwHt+fO7+EGt/b9/slnUmxOUbD61s6haG4MAhSAZ4T5TRsu1YDhZOPj59I+Wui6CP8j0E8T4QVNZuk4iFn+wsR1Z5rMZ+23kz3npjW7hOKJZcHiCh4Lv0+7IAf4sYmC3aawF+9gn8cJPMqI2Cb7uOlVMybQsCqlrl/YaENiWfq0HyeF4EIEcOwBEfHwhFf9OHW7cIOrVeJSMq1bmXeGTRZBtNhP+zjb3K8Qv1oNS2QEI8Mv3hUNjedUXQ6wXMUGBxc/Etmnph74PzXzz8tzrq1lgUFHqjmj8tfRsYpWk48f8a5Oe6P9/0BwCq4U7"
}

resource "aws_launch_configuration" "instance" {
  name_prefix                 = "${var.project_name}-instance-"
  instance_type               = var.instance_type
  image_id                    = data.aws_ami.ecs_ami.id
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.instance.name
  key_name                    = aws_key_pair.app_instance_key.key_name
  security_groups = [
    var.default_security_group_id,
    aws_security_group.application_sg.id,
    var.db_access_security_group_id
  ]

  user_data = <<-EOF
                  #!/bin/bash
                  echo ECS_CLUSTER=${aws_ecs_cluster.ecs_cluster.name} >> /etc/ecs/ecs.config
                EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name = "${var.project_name}-${var.environment_name}-asg"

  launch_configuration = aws_launch_configuration.instance.name
  termination_policies = ["OldestLaunchConfiguration", "Default"]
  vpc_zone_identifier  = var.public_subnet_ids
  target_group_arns    = [var.lb_target_group_arn]
  max_size             = 3
  min_size             = 1

  health_check_grace_period = 300
  health_check_type         = "EC2"

  lifecycle {
    create_before_destroy = true
  }
}
