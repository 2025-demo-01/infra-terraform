resource "aws_route53recoverycontrolconfig_cluster" "this" {
  name = "${var.name_prefix}-arc-cluster"
  tags = var.tags
}

resource "aws_route53recoverycontrolconfig_control_panel" "panel" {
  name     = "${var.name_prefix}-panel"
  cluster_arn = aws_route53recoverycontrolconfig_cluster.this.arn
  tags     = var.tags
}

# 두 region에 대한 routing control(Active/Passive)
resource "aws_route53recoverycontrolconfig_routing_control" "primary" {
  name            = "${var.name_prefix}-rc-primary"
  control_panel_arn = aws_route53recoverycontrolconfig_control_panel.panel.arn
  tags            = var.tags
}
resource "aws_route53recoverycontrolconfig_routing_control" "secondary" {
  name              = "${var.name_prefix}-rc-secondary"
  control_panel_arn = aws_route53recoverycontrolconfig_control_panel.panel.arn
  tags              = var.tags
}

# safety rule 둘 다 ON 금지(한쪽만 active)
resource "aws_route53recoverycontrolconfig_safety_rule" "assert_one" {
  name              = "${var.name_prefix}-assert-one-up"
  control_panel_arn = aws_route53recoverycontrolconfig_control_panel.panel.arn
  rule_config {
    inverted           = false
    threshold          = 1
    type               = "ATLEAST"
  }
  gating_controls = [
    aws_route53recoverycontrolconfig_routing_control.primary.arn,
    aws_route53recoverycontrolconfig_routing_control.secondary.arn
  ]
  wait_period_ms = 5000
  tags           = var.tags
}
