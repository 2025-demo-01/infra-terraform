locals {
  tags = merge({
    project = "upx-exchange"
    owner   = "data-platform"
  }, var.tags)
}

resource "aws_security_group" "msk" {
  name        = "${var.cluster_name}-msk-sg"
  description = "MSK cluster security group"
  vpc_id      = var.vpc_id

  ingress {
    from_port                = 9092
    to_port                  = 9098
    protocol                 = "tcp"
    security_groups          = [var.client_security_group_id] # ← 새 변수로 받기
    description              = "EKS nodes only"
  }
  egress  { from_port = 0 to_port = 0 protocol = "-1" cidr_blocks = ["0.0.0.0/0"] }

  tags = local.tags
}


# SCRAM secret
resource "aws_secretsmanager_secret" "scram" {
  name = "${var.cluster_name}-msk-scram"
  tags = local.tags
}
resource "aws_secretsmanager_secret_version" "scram" {
  secret_id     = aws_secretsmanager_secret.scram.id
  secret_string = jsonencode({ username = var.sasl_username, password = var.sasl_password })
}

resource "aws_msk_cluster" "this" {
  cluster_name           = var.cluster_name
  kafka_version          = var.kafka_version
  number_of_broker_nodes = length(var.subnet_ids) * var.brokers_per_az

  broker_node_group_info {
    instance_type   = "kafka.m7g.large"
    client_subnets  = var.subnet_ids
    security_groups = [aws_security_group.msk.id]
  }

  client_authentication {
    sasl {
      scram = true
    }
  }

  encryption_info {
    encryption_at_rest_kms_key_arn = null
  }

  tags = local.tags
}

resource "aws_msk_scram_secret_association" "scram" {
  cluster_arn     = aws_msk_cluster.this.arn
  secret_arn_list = [aws_secretsmanager_secret.scram.arn]
}
