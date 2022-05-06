# compute/output.tf #
 output "instance" {
     value = aws_instance.kube_instances[*]
     sensitive = true
 }
