output "application_sg_id" { value = aws_security_group.application_sg.id }
output "service_name" { value = aws_ecs_service.ecs_service.name }
