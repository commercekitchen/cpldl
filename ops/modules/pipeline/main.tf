resource "aws_s3_bucket" "pipeline_store" {
  bucket        = "${var.project_name}-${var.environment_name}-pipeline-store"
  acl           = "private"
  force_destroy = true
}

resource "aws_s3_bucket_public_access_block" "block_public_access" {
  bucket = aws_s3_bucket.pipeline_store.id

  block_public_acls   = true
  block_public_policy = true
}

resource "aws_codestarconnections_connection" "repo_actions" {
  name          = "${var.project_name}-${var.environment_name}-codestar"
  provider_type = "GitHub"
}

data "template_file" "buildspec" {
  template = file("${path.module}/buildspec.yml")

  vars = {
    ecr_repository_url = var.ecr_repository_url
    ecr_project_uri    = var.ecr_project_uri
    region             = var.region
    rails_env          = var.environment_name
    cluster_name       = var.ecs_cluster_name
    rails_master_key   = var.rails_master_key
    docker_username    = var.docker_username
    docker_password    = var.docker_password
  }
}

resource "aws_codebuild_project" "codebuild_project" {
  name          = "${var.project_name}-${var.environment_name}-codebuild-project"
  build_timeout = 10
  service_role  = aws_iam_role.codebuild_role.arn

  artifacts {
    type = "CODEPIPELINE"
  }

  environment {
    compute_type    = "BUILD_GENERAL1_SMALL"
    image           = "aws/codebuild/standard:5.0"
    type            = "LINUX_CONTAINER"
    privileged_mode = true
  }

  source {
    type      = "CODEPIPELINE"
    buildspec = data.template_file.buildspec.rendered
  }
}


