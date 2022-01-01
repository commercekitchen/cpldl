variable "adjustment_type" {
  default     = "ChangeInCapacity"
  description = "Options: ChangeInCapacity, ExactCapacity, and PercentChangeInCapacity"
}

variable "policy_cooldown" {
  default     = 300
  description = "The amount of time, in seconds, after a scaling activity completes and before the next scaling activity can start."
}

resource "aws_autoscaling_policy" "up" {
  name                   = "${aws_ecs_cluster.ecs_cluster.name}-scaleUp"
  scaling_adjustment     = 1
  adjustment_type        = var.adjustment_type
  cooldown               = var.policy_cooldown
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  count                  = 1
}

resource "aws_autoscaling_policy" "down" {
  name                   = "${aws_ecs_cluster.ecs_cluster.name}-scaleDown"
  scaling_adjustment     = -1
  adjustment_type        = var.adjustment_type
  cooldown               = var.policy_cooldown
  policy_type            = "SimpleScaling"
  autoscaling_group_name = aws_autoscaling_group.asg.name
  count                  = 1
}

/*
 * Create CloudWatch alarms to trigger scaling of ASG
 */
resource "aws_cloudwatch_metric_alarm" "scaleUp" {
  alarm_name          = "${aws_ecs_cluster.ecs_cluster.name}-scaleUp"
  alarm_description   = "ECS cluster scaling metric above threshold"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  period              = 120
  threshold           = 80
  actions_enabled     = true
  count               = 1
  alarm_actions       = [aws_autoscaling_policy.up[0].arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
  }
}

resource "aws_cloudwatch_metric_alarm" "scaleDown" {
  alarm_name          = "${aws_ecs_cluster.ecs_cluster.name}-scaleDown"
  alarm_description   = "ECS cluster scaling metric under threshold"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUReservation"
  namespace           = "AWS/ECS"
  statistic           = "Average"
  period              = 120
  threshold           = 50
  actions_enabled     = true
  count               = 1
  alarm_actions       = [aws_autoscaling_policy.down[0].arn]

  dimensions = {
    ClusterName = aws_ecs_cluster.ecs_cluster.name
  }
}
