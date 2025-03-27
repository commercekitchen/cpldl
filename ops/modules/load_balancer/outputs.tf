output "load_balancer_sg_id" { value = aws_security_group.load_balancer_sg.id }
output "load_balancer_name" { value = aws_lb.load_balancer.name }
output "lb_target_group_arn" { value = aws_lb_target_group.load_balancer_tg.arn }
output "load_balancer_arn" { value = aws_lb.load_balancer.arn }