resource "aws_autoscaling_group" "sidekiq_asg" {
  name                      = "${var.project_name}-${var.environment_name}-sidekiq-asg"
  max_size                  = var.max_task_count
  min_size                  = var.min_task_count
  vpc_zone_identifier       = var.public_subnet_ids

  launch_template {
    id      = aws_launch_template.instance.id
    version = "$Latest"
  }

  health_check_type         = "EC2"
  health_check_grace_period = 300

  termination_policies = ["OldestLaunchTemplate", "Default"]

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


  lifecycle {
    create_before_destroy = true
  }
}

