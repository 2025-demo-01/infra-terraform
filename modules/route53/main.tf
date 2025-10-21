############################
# Hosted Zone + (옵션) Failover 레코드
############################

variable "primary_value" {
  type    = string
  default = null  # ALB DNS, NLB DNS 또는 정적 IP 등
}
variable "secondary_value" {
  type    = string
  default = null
}

resource "aws_route53_zone" "root" {
  name = var.root_domain
  tags = var.tags
}

# Health check는 실제 엔드포인트가 있어야 유효 → 값이 있을 때만 생성
resource "aws_route53_health_check" "primary" {
  count             = var.failover_enable && var.primary_value != null ? 1 : 0
  fqdn              = var.primary_value
  type              = "HTTPS"
  resource_path     = "/healthz"
  failure_threshold = 3
  request_interval  = 30
  tags              = var.tags
}

resource "aws_route53_health_check" "secondary" {
  count             = var.failover_enable && var.secondary_value != null ? 1 : 0
  fqdn              = var.secondary_value
  type              = "HTTPS"
  resource_path     = "/healthz"
  failure_threshold = 3
  request_interval  = 30
  tags              = var.tags
}

# Failover A(Primary)
resource "aws_route53_record" "primary" {
  count   = var.failover_enable && var.primary_value != null ? 1 : 0
  zone_id = aws_route53_zone.root.zone_id
  name    = "app.${var.root_domain}"
  type    = "CNAME"
  ttl     = 30
  records = [var.primary_value]
  failover_routing_policy {
    type = "PRIMARY"
  }
  set_identifier   = "primary"
  health_check_id  = aws_route53_health_check.primary[0].id
}

# Failover B(Secondary)
resource "aws_route53_record" "secondary" {
  count   = var.failover_enable && var.secondary_value != null ? 1 : 0
  zone_id = aws_route53_zone.root.zone_id
  name    = "app.${var.root_domain}"
  type    = "CNAME"
  ttl     = 30
  records = [var.secondary_value]
  failover_routing_policy {
    type = "SECONDARY"
  }
  set_identifier  = "secondary"
  health_check_id = aws_route53_health_check.secondary[0].id
}
