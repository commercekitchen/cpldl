output "application_sg_id" { value = aws_security_group.application_sg.id }
output "cluster_name" { value = aws_ecs_cluster.ecs_cluster.name }
output "service_name" { value = aws_ecs_service.ecs_service.name }
