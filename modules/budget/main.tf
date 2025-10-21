resource "aws_budgets_budget" "monthly" {
  name              = var.name
  budget_type       = "COST"
  limit_amount      = tostring(var.limit_amount)
  limit_unit        = "USD"
  time_unit         = "MONTHLY"

  notification {
    comparison_operator = "GREATER_THAN"
    threshold           = 80
    threshold_type      = "PERCENTAGE"
    notification_type   = "FORECASTED"
    subscriber_email_addresses = [var.email]
  }
}
