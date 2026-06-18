output "site_url" {
  value = "http://${aws_lb.public.dns_name}"
}

output "internal_alb_dns" {
  value = aws_lb.internal.dns_name
}

output "rds_endpoint" {
  value = data.aws_db_instance.postgres.address
}

output "web_ips" {
  value = aws_instance.web[*].public_ip
}

output "app_ips" {
  value = aws_instance.app[*].private_ip
}
