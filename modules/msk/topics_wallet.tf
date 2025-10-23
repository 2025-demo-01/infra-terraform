resource "kafka_topic" "wallet_tx" {
  name               = "wallet.tx"
  partitions         = 12
  replication_factor = 3
  config = {
    "cleanup.policy" = "delete"
    "retention.ms"   = "172800000" # 2 days
  }
}

# ACL도 provider/방식에 맞춰 추가 (SASL 유저 기준)
# resource "kafka_acl" "wallet_producer" { ... }
