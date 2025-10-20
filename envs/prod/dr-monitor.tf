# Aurora Replica Lag 알람 (멀티리전/리더-리더 시나리오 대비)
variable "aurora_secondary_cluster_id" {
  type    = string
  default = "upx-aurora-apne1" # 실제 값으로 교체
}

resource "aws_cloudwatch_metric_alarm" "aurora_replica_lag" {
  alarm_name          = "aurora-replica-lag"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "AuroraReplicaLag"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 5
  dimensions = {
    DBClusterIdentifier = var.aurora_secondary_cluster_id
  }
  alarm_description = "Aurora cross-region replica lag > 5s"
}
