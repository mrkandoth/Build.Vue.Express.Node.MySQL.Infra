output "cluster_id" {
  value = aws_ecs_cluster.nbc-lab.id
}

output "service_name" {
  value = aws_ecs_service.nbc-lab.name
}

output "security_group_id" {
  value = aws_security_group.nbc-lab.id
}

output "nbc-lab-load_balancer" {
  value = aws_lb.nbc-lab.dns_name
}

output "nbc-lab-ecs-cluster-name" {
  value = aws_ecs_cluster.nbc-lab
}

output "nbc-lab-ecs-service-name" {
  value = aws_ecs_service.nbc-lab
}
