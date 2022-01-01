output "database_host" { value = aws_db_instance.app_db.address }
output "db_access_security_group_id" { value = aws_security_group.db_access_sg.id }
