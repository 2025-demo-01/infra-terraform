variable "region"               { type = string  default = "ap-northeast-2" }
variable "cluster_name"         { type = string  default = "upx-eks-dev" }
variable "vpc_id"               { type = string }
variable "private_subnet_ids"   { type = list(string) }
variable "public_subnet_ids"    { type = list(string) }
variable "kubernetes_version"   { type = string  default = "1.29" }
variable "karpenter_version"    { type = string  default = "v0.37.0" }
variable "domain_root"          { type = string  default = "dev.upx.exchange" }

variable "tags" {
  type    = map(string)
  default = { env = "dev", owner = "platform", project = "upx-exchange" }
}

# MSK
variable "kafka_version"        { type = string  default = "3.6.0" }
variable "msk_brokers_per_az"   { type = number  default = 1 }
variable "msk_sasl_username"    { type = string  default = "sophielog" }
variable "msk_sasl_password"    { type = string  default = "sophielog" }

# Aurora
variable "aurora_engine"        { type = string  default = "aurora-mysql" }
variable "aurora_engine_version"{ type = string  default = "8.0.mysql_aurora.3.06.0" }
variable "aurora_master_user"   { type = string  default = "admin" }
variable "aurora_master_pass"   { type = string  default = "sophielog" }

# ClickHouse
variable "clickhouse_namespace" { type = string  default = "analytics" }
variable "clickhouse_replicas"  { type = number  default = 1 }
variable "clickhouse_storage"   { type = string  default = "50Gi" }

# DR
variable "primary_record"       { type = string  default = "api.dev.upx.exchange" }
variable "dr_secondary_record"  { type = string  default = "api-dr.dev.upx.exchange" }
variable "primary_alb_arn"      { type = string  default = "" }
variable "secondary_alb_arn"    { type = string  default = "" }
