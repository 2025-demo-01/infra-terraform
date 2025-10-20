locals {
  tags = merge({
    project = "upx-exchange"
    owner   = "platform"
  }, var.tags)
}

data "aws_route53_zone" "zone" {
  name         = "${var.hosted_zone}."
  private_zone = false
}

data "aws_lb" "primary"   { arn = var.primary_alb_arn }
data "aws_lb" "secondary" { arn = var.secondary_alb_arn }

resource "aws_route53_health_check" "primary" {
  fqdn              = data.aws_lb.primary.dns_name
  port              = 443
  type              = "HTTPS"
  resource_path     = var.hc_primary_path
  failure_threshold = 3
  request_interval  = 30
  tags              = local.tags
}

resource "aws_route53_health_check" "secondary" {
  fqdn              = data.aws_lb.secondary.dns_name
  port              = 443
  type              = "HTTPS"
  resource_path     = var.hc_secondary_path
  failure_threshold = 3
  request_interval  = 30
  tags              = local.tags
}

# Failover A records (ALIAS to ALB)
resource "aws_route53_record" "primary" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.primary_record
  type    = "A"
  set_identifier = "primary"
  failover_routing_policy { type = "PRIMARY" }
  alias {
    name                   = data.aws_lb.primary.dns_name
    zone_id                = data.aws_lb.primary.zone_id
    evaluate_target_health = true
  }
  health_check_id = aws_route53_health_check.primary.id
}

resource "aws_route53_record" "secondary" {
  zone_id = data.aws_route53_zone.zone.zone_id
  name    = var.secondary_record
  type    = "A"
  set_identifier = "secondary"
  failover_routing_policy { type = "SECONDARY" }
  alias {
    name                   = data.aws_lb.secondary.dns_name
    zone_id                = data.aws_lb.secondary.zone_id
    evaluate_target_health = true
  }
  health_check_id = aws_route53_health_check.secondary.id
}
