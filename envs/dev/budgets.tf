resource "aws_budgets_budget" "monthly" {
  name              = "upx-${var.tags["env"]}-monthly"
  budget_type       = "COST"
  limit_amount      = "5000"        # 환경에 맞게
  limit_unit        = "USD"
  time_unit         = "MONTHLY"
  cost_filters      = { "TagKeyValue" = ["env$${var.tags["env"]}"] }
  notification {
    comparison_operator = "GREATER_THAN"
    threshold           = 80
    threshold_type      = "PERCENTAGE"
    notification_type   = "ACTUAL"
    subscriber_sns_topic_arns = ["arn:aws:sns:${var.region}:123456789012:budgets-alerts"]
  }
}
