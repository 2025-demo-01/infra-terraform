output "cluster_name"        { value = module.eks.cluster_name }
output "cluster_endpoint"    { value = module.eks.cluster_endpoint }
output "cluster_ca"          { value = module.eks.cluster_certificate_authority_data }
output "oidc_provider_arn"   { value = module.eks.oidc_provider_arn }
output "oidc_issuer_url"     { value = module.eks.oidc_issuer_url }

output "private_subnet_ids"  { value = module.vpc.private_subnet_ids }
output "public_subnet_ids"   { value = module.vpc.public_subnet_ids }
output "vpc_id"              { value = module.vpc.vpc_id }

output "msk_bootstrap_brokers" { value = module.msk.bootstrap_brokers_tls }
output "aurora_writer_endpoint"{ value = module.aurora.writer_endpoint }
output "aurora_reader_endpoint"{ value = module.aurora.reader_endpoint }
output "clickhouse_endpoint"   { value = module.clickhouse.endpoint }

output "external_dns_irsa_role_arn" { value = module.irsa.role_arns["external_dns"] }
output "alb_controller_irsa_role_arn" { value = module.irsa.role_arns["alb_controller"] }

output "route53_zone_id"      { value = module.route53.zone_id }
output "route53_failover_a"   { value = module.route53.failover_primary_fqdn }
output "route53_failover_b"   { value = module.route53.failover_secondary_fqdn }
