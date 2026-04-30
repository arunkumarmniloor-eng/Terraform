output "alb_dns_name" {
  description = "Access your application at this URL"
  value       = aws_lb.main_alb.dns_name
}

output "flask_ecr_url" {
  value = aws_ecr_repository.flask_repo.repository_url
}

output "express_ecr_url" {
  value = aws_ecr_repository.express_repo.repository_url
}

