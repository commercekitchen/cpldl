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

data "template_file" "codepipeline_policy_template" {
  template = file("${path.module}/policies/codepipeline_policy.json")

  vars = {
    aws_s3_bucket_arn       = aws_s3_bucket.pipeline_store.arn
    codestar_connection_arn = aws_codestarconnections_connection.repo_actions.arn
  }
}

resource "aws_iam_role_policy" "codepipeline_policy" {
  name   = "${var.project_name}-${var.environment_name}-codepipeline-policy"
  role   = aws_iam_role.codepipeline_role.id
  policy = data.template_file.codepipeline_policy_template.rendered
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

data "template_file" "codebuild_policy_template" {
  template = file("${path.module}/policies/codebuild_policy.json")

  vars = {
    aws_s3_bucket_arn = aws_s3_bucket.pipeline_store.arn
  }
}

resource "aws_iam_role_policy" "codebuild_policy" {
  name   = "${var.project_name}-${var.environment_name}-codebuild-policy"
  role   = aws_iam_role.codebuild_role.id
  policy = data.template_file.codebuild_policy_template.rendered
}

