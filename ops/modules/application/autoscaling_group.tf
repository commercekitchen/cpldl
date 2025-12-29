resource "aws_autoscaling_group" "asg" {
  name = "${var.project_name}-${var.environment_name}-asg"

  launch_template {
    id      = aws_launch_template.instance.id
    version = "$Latest"
  }

  termination_policies = ["OldestLaunchTemplate", "Default"]
  vpc_zone_identifier  = var.public_subnet_ids
  max_size             = var.max_instance_count
  min_size             = 1

  health_check_grace_period = 300
  health_check_type = "EC2"

  tag {
    key                 = "AmazonECSManaged"
    value               = "true"
    propagate_at_launch = true
  }

  # You can keep these tags, or rely on tag_specifications in the LT.
  tag {
    key                 = "ecs_cluster"
    value               = var.ecs_cluster_name
    propagate_at_launch = true
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name} App Instance ${var.environment_name}"
    propagate_at_launch = true
  }

  lifecycle {
    create_before_destroy = true
  }
}
