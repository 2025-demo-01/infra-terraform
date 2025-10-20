resource "aws_cloudwatch_metric_alarm" "aurora_replica_lag" {
  alarm_name          = "aurora-replica-lag"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 3
  metric_name         = "AuroraReplicaLag"
  namespace           = "AWS/RDS"
  period              = 60
  statistic           = "Average"
  threshold           = 5
  dimensions = { DBClusterIdentifier = "upx-aurora-apne1" }
}
