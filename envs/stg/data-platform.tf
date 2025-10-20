module "msk" {
  source          = "../../modules/msk"
  cluster_name    = "${var.cluster_name}-msk"
  region          = var.region
  vpc_id          = var.vpc_id
  subnet_ids      = module.network.private_subnet_ids
  kafka_version   = var.kafka_version
  brokers_per_az  = var.msk_brokers_per_az
  sasl_username   = var.msk_sasl_username
  sasl_password   = var.msk_sasl_password
  tags            = var.tags
}

module "opencost" {
  source       = "../../modules/opencost"
  namespace    = "opencost"
  cluster_name = var.cluster_name
  currency     = "USD"
  tags         = var.tags
}

module "clickhouse" {
  source              = "../../modules/clickhouse"
  namespace           = var.clickhouse_namespace
  replicas            = var.clickhouse_replicas
  storage_size        = var.clickhouse_storage
  zookeeper_endpoints = []
  tags                = var.tags
}

module "msk" {
  client_security_group_id = module.network.karpenter_security_group_id 
}
