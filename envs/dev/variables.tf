variable "name_prefix" {}
variable "region" {}

variable "vpc_cidr" {}
variable "public_subnets"  { type = list(string) }
variable "private_subnets" { type = list(string) }

variable "eks_version" {}
variable "node_instance_types" { type = list(string) }
variable "karpenter_instance_families" { type = list(string) }

variable "aurora_engine"         {}
variable "aurora_engine_version" {}
variable "aurora_instance_class" {}

variable "msk_kafka_version" {}

variable "clickhouse_admin_username" {}
