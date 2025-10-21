name_prefix   = "sophie-dev"
region        = "ap-northeast-2"

vpc_cidr      = "10.20.0.0/16"
public_subnets  = ["10.20.0.0/20", "10.20.16.0/20"]
private_subnets = ["10.20.32.0/20", "10.20.48.0/20"]

eks_version   = "1.29"
node_instance_types = ["m6i.large"]
karpenter_instance_families = ["c6i", "m6i"]

aurora_engine         = "aurora-postgresql"
aurora_engine_version = "15.4"
aurora_instance_class = "db.r6g.large"

msk_kafka_version = "3.6.0"

# ClickHouse: AWS Managed Service Setting
clickhouse_admin_username = "sophie"
