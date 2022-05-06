# loadbalancer / output.tf
output "lb_target_group_arn" {
    value = aws_lb_target_group.target_group.arn
}

output "lb_endpoint" {
    value = aws_lb.loadbalancer.dns_name
}
