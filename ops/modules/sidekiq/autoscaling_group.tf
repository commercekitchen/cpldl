resource "aws_autoscaling_group" "sidekiq_asg" {
  name                      = "${var.project_name}-${var.environment_name}-sidekiq-asg"

  launch_template {
    id      = aws_launch_template.instance.id
    version = "$Latest"
  }

  termination_policies = ["OldestLaunchTemplate", "Default"]
  vpc_zone_identifier  = var.public_subnet_ids
  max_size             = var.max_instance_count
  min_size             = 1

  health_check_type         = "EC2"
  health_check_grace_period = 300

  protect_from_scale_in = false # Don't prevent scaling in

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment_name}-sidekiq-instance"
    propagate_at_launch = true
  }

  tag {
    key                 = "AmazonECSManaged"
    value               = true
    propagate_at_launch = true
  }

  tag {
    key                 = "ecs_cluster"
    value               = var.ecs_cluster_name
    propagate_at_launch = true
  }

  tag {
    key = "Role"
    value = "sidekiq-server"
    propagate_at_launch = true
  }
}

