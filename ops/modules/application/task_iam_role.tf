data "aws_iam_policy_document" "ecs_task_assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "app_task_s3" {
  statement {
    sid      = "S3ListBucket"
    effect   = "Allow"
    actions  = ["s3:ListBucket"]
    resources = var.s3_bucket_arns
  }

  statement {
    sid     = "S3ObjectRW"
    effect  = "Allow"
    actions = [
      "s3:GetObject",
      "s3:PutObject",
      "s3:DeleteObject",

      # multipart
      "s3:CreateMultipartUpload",
      "s3:UploadPart",
      "s3:CompleteMultipartUpload",
      "s3:AbortMultipartUpload",
      "s3:ListMultipartUploadParts",
    ]
    resources = formatlist("%s/*", var.s3_bucket_arns)
  }

  statement {
    sid      = "S3GetBucketLocation"
    effect   = "Allow"
    actions  = ["s3:GetBucketLocation"]
    resources = var.s3_bucket_arns
  }
}

resource "aws_iam_policy" "app_task_s3" {
  name   = "${var.project_name}-${var.environment_name}-app-task-s3"
  path   = "/"
  policy = data.aws_iam_policy_document.app_task_s3.json
}

resource "aws_iam_role" "app_task_role" {
  name               = "${var.project_name}-${var.environment_name}-app-task-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_assume_role.json
}

resource "aws_iam_role_policy_attachment" "app_task_s3" {
  role       = aws_iam_role.app_task_role.name
  policy_arn = aws_iam_policy.app_task_s3.arn
}

