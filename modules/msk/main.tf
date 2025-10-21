############################
# MSK (Kafka) 최소 구성
############################

resource "aws_security_group" "msk" {
  name   = "${var.name_prefix}-msk-sg"
  vpc_id = var.vpc_id
  tags   = var.tags
}

resource "aws_msk_cluster" "this" {
  cluster_name           = "${var.name_prefix}-msk"
  kafka_version          = var.kafka_version
  number_of_broker_nodes = 3

  broker_node_group_info {
    instance_type   = "kafka.m5.large"
    client_subnets  = var.subnet_ids
    security_groups = [aws_security_group.msk.id]
  }

  encryption_info {
    encryption_in_transit { client_broker = "TLS" in_cluster = true }
  }

  tags = var.tags
}
