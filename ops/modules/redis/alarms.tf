resource "aws_sns_topic" "redis_alarm_topic" {
  name = "${var.project_name}-${var.environment_name}-redis-alarms"
}

resource "aws_sns_topic_policy" "redis_alarm_topic_policy" {
  arn    = aws_sns_topic.redis_alarm_topic.arn

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Sid       = "AllowCloudWatchPublish",
        Effect    = "Allow",
        Principal = {
          Service = "cloudwatch.amazonaws.com"
        },
        Action    = "SNS:Publish",
        Resource  = aws_sns_topic.redis_alarm_topic.arn
      }
    ]
  })
}

resource "aws_sns_topic_subscription" "redis_email_subscriptions" {
  for_each = toset(var.redis_alarm_emails)

  topic_arn = aws_sns_topic.redis_alarm_topic.arn
  protocol  = "email"
  endpoint  = each.value
}

resource "aws_cloudwatch_metric_alarm" "redis_evictions" {
  alarm_name          = "${var.project_name}-${var.environment_name}-redis-evictions"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "Evictions"
  namespace           = "AWS/ElastiCache"
  period              = 60
  statistic           = "Sum"
  threshold           = 0
  treat_missing_data = "notBreaching"
  alarm_description   = "Redis evicted keys — likely under memory pressure"
  dimensions = {
    ReplicationGroupId = aws_elasticache_replication_group.redis.id
  }
  alarm_actions = [aws_sns_topic.redis_alarm_topic.arn]
}

resource "aws_cloudwatch_metric_alarm" "redis_low_memory" {
  alarm_name          = "${var.project_name}-${var.environment_name}-redis-low-memory"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 2
  metric_name         = "FreeableMemory"
  namespace           = "AWS/ElastiCache"
  period              = 300
  statistic           = "Average"
  threshold           = 100000000  # ~100 MB
  treat_missing_data = "notBreaching"
  alarm_description   = "Redis has low free memory"
  dimensions = {
    CacheClusterId = "${aws_elasticache_replication_group.redis.id}-001"
  }
  alarm_actions = [aws_sns_topic.redis_alarm_topic.arn]
}