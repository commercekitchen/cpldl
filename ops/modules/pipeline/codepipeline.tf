resource "aws_codepipeline" "pipeline" {
  name     = "${var.project_name}-${var.environment_name}-pipeline"
  role_arn = aws_iam_role.codepipeline_role.arn

  artifact_store {
    location = aws_s3_bucket.pipeline_store.bucket
    type     = "S3"
  }

  stage {
    name = "Source"

    action {
      name             = "Source"
      category         = "Source"
      owner            = "AWS"
      provider         = "CodeStarSourceConnection"
      version          = "1"
      output_artifacts = ["source"]

      configuration = {
        ConnectionArn    = aws_codestarconnections_connection.repo_actions.arn
        FullRepositoryId = "${var.github_owner}/${var.github_repo}"
        BranchName       = var.branch
      }
    }
  }

  stage {
    name = "Build"

    action {
      name             = "Build"
      category         = "Build"
      owner            = "AWS"
      provider         = "CodeBuild"
      version          = "1"
      input_artifacts  = ["source"]
      output_artifacts = ["build_output"]

      configuration = {
        ProjectName = aws_codebuild_project.codebuild_project.name
      }
    }
  }

  stage {
    name = "Deploy"

    action {
      name            = "DeployWeb"
      category        = "Deploy"
      owner           = "AWS"
      provider        = "ECS"
      version         = "1"
      input_artifacts = ["build_output"]
      run_order       = 1

      configuration = {
        ClusterName = var.ecs_cluster_name
        ServiceName = var.app_service_name
        FileName    = "imagedefinitions.json"
      }
    }

    action {
      name             = "DeploySidekiq"
      category         = "Deploy"
      owner            = "AWS"
      provider         = "ECS"
      version          = "1"
      input_artifacts  = ["build_output"]
      run_order        = 2

      configuration = {
        ClusterName = var.ecs_cluster_name
        ServiceName = var.sidekiq_service_name
        FileName    = "imagedefinitions_sidekiq.json"
      }
    }
  }
}
