output "bootstrap_brokers"       { value = aws_msk_cluster.this.bootstrap_brokers }
output "bootstrap_brokers_sasl"  { value = aws_msk_cluster.this.bootstrap_brokers_sasl_scram }
output "security_group_id"       { value = aws_security_group.msk.id }
output "cluster_arn"             { value = aws_msk_cluster.this.arn }
