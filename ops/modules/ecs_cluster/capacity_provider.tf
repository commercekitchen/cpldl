resource "aws_ecs_cluster_capacity_providers" "cluster_capacity_providers" {
  cluster_name = aws_ecs_cluster.ecs_cluster.name

  capacity_providers = [
    var.app_capacity_provider_name,
    var.sidekiq_capacity_provider_name,
  ]

  default_capacity_provider_strategy {
    base              = 0
    weight            = 1
    capacity_provider = var.app_capacity_provider_name
  }
}