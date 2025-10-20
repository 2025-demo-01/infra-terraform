output "cluster_name"      { value = module.eks.cluster_name }
output "cluster_endpoint"  { value = module.eks.cluster_endpoint }
output "cluster_ca"        { value = module.eks.cluster_ca }
output "nodegroup_role"    { value = module.eks.nodegroup_role_name }

output "msk_bootstrap"     { value = module.msk.bootstrap_brokers_sasl }
output "aurora_endpoint"   { value = module.aurora.cluster_endpoint }
output "aurora_reader"     { value = module.aurora.reader_endpoint }
output "clickhouse_ns"     { value = module.clickhouse.namespace }

output "dr_primary_hc_id"  { value = module.dr.primary_healthcheck_id }
output "dr_secondary_hc_id"{ value = module.dr.secondary_healthcheck_id }
