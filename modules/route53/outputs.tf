output "zone_id"                { value = aws_route53_zone.root.zone_id }
output "failover_primary_fqdn"  { value = aws_route53_record.primary.fqdn }
output "failover_secondary_fqdn"{ value = aws_route53_record.secondary.fqdn }
