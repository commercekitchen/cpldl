# ops/modules/vpc/flow_logs.tf
resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name              = "/aws/vpc/flow-logs/${var.project_name}-${var.environment_name}"
  retention_in_days = 90
}

data "aws_iam_policy_document" "vpc_flow_logs_assume" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "vpc_flow_logs" {
  name               = "${var.project_name}-${var.environment_name}-vpc-flow-logs"
  assume_role_policy = data.aws_iam_policy_document.vpc_flow_logs_assume.json
}

data "aws_iam_policy_document" "vpc_flow_logs_write" {
  statement {
    effect  = "Allow"
    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams"
    ]
    resources = [
      aws_cloudwatch_log_group.vpc_flow_logs.arn,
      "${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"
    ]
  }
}

resource "aws_iam_role_policy" "vpc_flow_logs_write" {
  role   = aws_iam_role.vpc_flow_logs.id
  policy = data.aws_iam_policy_document.vpc_flow_logs_write.json
}

resource "aws_flow_log" "vpc" {
  vpc_id               = aws_vpc.vpc.id
  log_destination      = aws_cloudwatch_log_group.vpc_flow_logs.arn
  log_destination_type = "cloud-watch-logs"
  traffic_type         = "ALL"
  iam_role_arn         = aws_iam_role.vpc_flow_logs.arn
}
