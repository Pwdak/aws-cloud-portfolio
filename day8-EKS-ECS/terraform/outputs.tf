output "ecr_repository_url" {
  value = aws_ecr_repository.app.repository_url
}

output "ecs_alb_dns_name" {
  value = aws_lb.ecs.dns_name
}
