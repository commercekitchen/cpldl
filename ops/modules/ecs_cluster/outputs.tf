output "cluster_name" { value = aws_ecs_cluster.ecs_cluster.name }
output "cluster_arn" { value = aws_ecs_cluster.ecs_cluster.arn }
output "cluster_id" { value = aws_ecs_cluster.ecs_cluster.id }
output "ecs_task_execution_role_arn" {
  value = aws_iam_role.ecs_task_execution_role.arn
}