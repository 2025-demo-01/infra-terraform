resource "aws_ssm_parameter" "wallet_pg_dsn" {
  name  = "/exchange/dev/wallet/pg_dsn"
  type  = "SecureString"
  value = "postgres://wallet_user:REDACTED@aurora-postgres.dev.cluster:5432/wallet"  # 실제 값
}

resource "aws_ssm_parameter" "kafka_brokers" {
  name  = "/exchange/dev/kafka/brokers"
  type  = "String"
  value = "b-1.msk.dev:9094,b-2.msk.dev:9094"
}

