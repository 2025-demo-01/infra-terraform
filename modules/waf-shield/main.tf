locals { scope = "REGIONAL" }

# (선택) 로그 버킷
resource "aws_s3_bucket" "waf_logs" {
  count  = var.enable_logging && var.log_bucket_name == null ? 1 : 0
  bucket = "${var.name_prefix}-waf-logs"
  force_destroy = true
  tags = var.tags
}

resource "aws_s3_bucket_server_side_encryption_configuration" "waf_logs" {
  count  = var.enable_logging && var.log_bucket_name == null ? 1 : 0
  bucket = aws_s3_bucket.waf_logs[0].id
  rule { apply_server_side_encryption_by_default { sse_algorithm = "AES256" } }
}

resource "aws_s3_bucket_versioning" "waf_logs" {
  count  = var.enable_logging && var.log_bucket_name == null ? 1 : 0
  bucket = aws_s3_bucket.waf_logs[0].id
  versioning_configuration { status = "Enabled" }
}

# Web ACL
resource "aws_wafv2_web_acl" "this" {
  name  = "${var.name_prefix}-web-acl"
  scope = local.scope
  default_action { allow {} }

  # AWS Managed Rules
  rule {
    name     = "AWSCommon"
    priority = 10
    statement { managed_rule_group_statement { name = "AWSManagedRulesCommonRuleSet" vendor_name = "AWS" } }
    visibility_config { cloudwatch_metrics_enabled = true metric_name = "common" sampled_requests_enabled = true }
    override_action { none {} }
  }

  rule {
    name     = "AWSKnownBadInputs"
    priority = 20
    statement { managed_rule_group_statement { name = "AWSManagedRulesKnownBadInputsRuleSet" vendor_name = "AWS" } }
    visibility_config { cloudwatch_metrics_enabled = true metric_name = "badinputs" sampled_requests_enabled = true }
    override_action { none {} }
  }

  rule {
    name     = "AWSIPReputation"
    priority = 30
    statement { managed_rule_group_statement { name = "AWSManagedRulesAmazonIpReputationList" vendor_name = "AWS" } }
    visibility_config { cloudwatch_metrics_enabled = true metric_name = "iprep" sampled_requests_enabled = true }
    override_action { none {} }
  }

  dynamic "rule" {
    for_each = var.enable_bot_control ? [1] : []
    content {
      name     = "AWSBotControl"
      priority = 40
      statement { managed_rule_group_statement { name = "AWSManagedRulesBotControlRuleSet" vendor_name = "AWS" } }
      visibility_config { cloudwatch_metrics_enabled = true metric_name = "bot" sampled_requests_enabled = true }
      override_action { none {} }
    }
  }

  # Rate limit
  dynamic "rule" {
    for_each = var.enable_rate_limit ? [1] : []
    content {
      name     = "RateLimit"
      priority = 50
      statement {
        rate_based_statement {
          limit              = var.rate_limit
          aggregate_key_type = "IP"
        }
      }
      visibility_config { cloudwatch_metrics_enabled = true metric_name = "rate" sampled_requests_enabled = true }
      action { block {} }
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "${var.name_prefix}-web-acl"
    sampled_requests_enabled   = true
  }

  tags = var.tags
}

# Association to ALB
resource "aws_wafv2_web_acl_association" "alb" {
  resource_arn = var.alb_arn
  web_acl_arn  = aws_wafv2_web_acl.this.arn
}

# Logging
resource "aws_wafv2_web_acl_logging_configuration" "this" {
  count = var.enable_logging ? 1 : 0

  log_destination_configs = [
    var.log_bucket_name != null
      ? "arn:aws:s3:::${var.log_bucket_name}"
      : "arn:aws:s3:::${aws_s3_bucket.waf_logs[0].id}"
  ]
  resource_arn = aws_wafv2_web_acl.this.arn
}

# (옵션) Shield Advanced 보호 – 계정이 구독 상태여야 함
resource "aws_shield_protection" "alb" {
  count        = var.enable_shield_advanced ? 1 : 0
  name         = "${var.name_prefix}-alb-protection"
  resource_arn = var.alb_arn
}

resource "aws_shield_protection" "route53" {
  count        = var.enable_shield_advanced && var.route53_zone_id != null ? 1 : 0
  name         = "${var.name_prefix}-r53-protection"
  resource_arn = "arn:aws:route53:::hostedzone/${var.route53_zone_id}"
}
