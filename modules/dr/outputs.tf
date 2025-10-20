output "primary_healthcheck_id"   { value = aws_route53_health_check.primary.id }
output "secondary_healthcheck_id" { value = aws_route53_health_check.secondary.id }
