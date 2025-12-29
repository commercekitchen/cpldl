#############################################
# Assume role policy (no heredoc JSON)
#############################################

data "aws_iam_policy_document" "ecs_instance_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

#############################################
# Inline policy for app-specific permissions
#############################################

data "aws_iam_policy_document" "ecs_instance_inline" {
  statement {
    sid     = "CloudwatchPutMetricData"
    effect  = "Allow"
    actions = ["cloudwatch:PutMetricData"]
    resources = ["*"]
  }

  statement {
    sid    = "InstanceLogging"
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]
    resources = [
      aws_cloudwatch_log_group.instance.arn,
      "${aws_cloudwatch_log_group.instance.arn}:log-stream:*",
    ]
  }

  ###########################################
  # S3: bucket-level vs object-level
  ###########################################

  # ListBucket must be against the *bucket ARN*
  statement {
    sid     = "S3ListBuckets"
    effect  = "Allow"
    actions = ["s3:ListBucket"]
    resources = var.s3_bucket_arns
  }

  # Object operations must be against bucket/* ARNs
  statement {
    sid     = "S3ObjectRW"
    effect  = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
    ]
    resources = formatlist("%s/*", var.s3_bucket_arns)
  }

  statement {
    sid     = "S3GetBucketLocation"
    effect  = "Allow"
    actions = [
      "s3:GetBucketLocation",
    ]
    resources = var.s3_bucket_arns
  }
}

resource "aws_iam_policy" "ecs_instance_inline" {
  name   = "${var.project_name}-${var.environment_name}-ecs-instance-inline"
  path   = "/"
  policy = data.aws_iam_policy_document.ecs_instance_inline.json
}

#############################################
# Role + attachments
#############################################

resource "aws_iam_role" "ecs_instance" {
  name               = "${var.project_name}-${var.environment_name}-ecs-instance-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_instance_assume_role.json
}

# Current ECS container instance managed policy
resource "aws_iam_role_policy_attachment" "ecs_container_instance" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

# Access via SSM
resource "aws_iam_role_policy_attachment" "ssm_core" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_role_policy_attachment" "inline" {
  role       = aws_iam_role.ecs_instance.name
  policy_arn = aws_iam_policy.ecs_instance_inline.arn
}

resource "aws_iam_instance_profile" "ecs_instance" {
  name = "${var.project_name}-${var.environment_name}-ecs-instance-profile"
  role = aws_iam_role.ecs_instance.name
}
