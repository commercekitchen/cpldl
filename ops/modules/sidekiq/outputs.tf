output "service_name" {
  value = aws_ecs_service.sidekiq.name
}

output "task_definition_family" {
  value = aws_ecs_task_definition.sidekiq.family
}

output "capacity_provider_name" { value = aws_ecs_capacity_provider.sidekiq_capacity_provider.name }