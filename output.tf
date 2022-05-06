# root/output.tf #

output "load_balancer_endpoint" {
    value = module.loadbalancer.lb_endpoint
}

output "instances" {
    value = {for i in module.compute.instance : i.tags.Name => i.public_ip}
    sensitive = true
}