# ecs_cluster/iam.tf (or similar)
resource "aws_iam_role" "ecs_task_execution_role" {
  name = "${var.project_name}-${var.environment_name}-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

# Base execution policy (pull from ECR, send logs, etc.)
resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# Secrets access policy (for RAILS_MASTER_KEY)
resource "aws_iam_policy" "ecs_execution_secrets" {
  name        = "${var.project_name}-${var.environment_name}-ecs-execution-secrets"
  description = "Allow ECS task execution role to read app secrets"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["secretsmanager:GetSecretValue"]
        Resource = [var.rails_master_key_arn]
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_secrets_attachment" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = aws_iam_policy.ecs_execution_secrets.arn
}
