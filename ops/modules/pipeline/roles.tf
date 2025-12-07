resource "aws_iam_role" "codepipeline_role" {
  name = "${var.project_name}-${var.environment_name}-codepipeline-role"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codepipeline.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

locals {
  codepipeline_policy_template = templatefile("${path.module}/policies/codepipeline_policy.json", {
    aws_s3_bucket_arn       = aws_s3_bucket.pipeline_store.arn
    codestar_connection_arn = aws_codestarconnections_connection.repo_actions.arn
  })
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "${var.project_name}-${var.environment_name}-codepipeline-policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = local.codepipeline_policy_template
}

resource "aws_iam_role" "codebuild_role" {
  name               = "${var.project_name}-${var.environment_name}-codebuild-role"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "codebuild.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

locals {
  codebuild_policy_template = templatefile("${path.module}/policies/codebuild_policy.json", {
    aws_s3_bucket_arn = aws_s3_bucket.pipeline_store.arn
    dockerhub_secret_arn    = var.dockerhub_secret_arn
    rails_master_key_arn    = var.rails_master_key_arn
  })
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "${var.project_name}-${var.environment_name}-codebuild-policy"
  role   = aws_iam_role.codebuild_role.id
  policy = local.codebuild_policy_template
}