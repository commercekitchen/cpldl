data "aws_iam_policy_document" "instance_policy" {
  statement {
    sid = "CloudwatchPutMetricData"

    actions = [
      "cloudwatch:PutMetricData",
    ]

    resources = [
      "*",
    ]
  }

  statement {
    sid = "InstanceLogging"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents",
      "logs:DescribeLogStreams",
    ]

    resources = [
      "${aws_cloudwatch_log_group.instance.arn}",
    ]
  }

  statement {
    sid = "LoadBalancer"

    actions = [
      "elasticloadbalancing:*",
    ]

    resources = [
      "*"
    ]
  }

  statement {
    sid = "ListObjectsInBucket"

    actions = [
      "s3:ListBucket"
    ]

    resources = var.s3_bucket_arns
  }

  statement {
    sid = "AllObjectActions"

    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:GetObjectAcl",
      "s3:PutObjectAcl",
      "s3:ListBucket",
      "s3:GetBucketAcl",
      "s3:PutBucketAcl",
      "s3:GetBucketLocation"
    ]

    resources = formatlist("%s/*", var.s3_bucket_arns)
  }
}

resource "aws_iam_policy" "instance_policy" {
  name   = "${var.project_name}-${var.environment_name}-ecs-instance"
  path   = "/"
  policy = data.aws_iam_policy_document.instance_policy.json
}

resource "aws_iam_role" "instance" {
  name = "${var.project_name}-${var.environment_name}-instance-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": ["ecs.amazonaws.com", "ec2.amazonaws.com"]
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_policy" {
  role       = aws_iam_role.instance.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEC2ContainerServiceforEC2Role"
}

resource "aws_iam_role_policy_attachment" "instance_policy" {
  role       = aws_iam_role.instance.name
  policy_arn = aws_iam_policy.instance_policy.arn
}

resource "aws_iam_instance_profile" "instance" {
  name = "${var.project_name}-${var.environment_name}-instance-profile"
  role = aws_iam_role.instance.name
}
