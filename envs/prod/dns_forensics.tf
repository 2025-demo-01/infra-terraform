resource "aws_s3_bucket" "dns_logs" {
  bucket = "${var.name_prefix}-dns-logs"
  object_lock_enabled = true
  tags = local.tags
}
resource "aws_s3_bucket_versioning" "dns_logs" {
  bucket = aws_s3_bucket.dns_logs.id
  versioning_configuration { status = "Enabled" }
}
resource "aws_s3_bucket_object_lock_configuration" "dns_logs" {
  bucket = aws_s3_bucket.dns_logs.id
  rule { default_retention { mode = "COMPLIANCE" days = 180 } }
}

resource "aws_route53_resolver_query_log_config" "this" {
  name            = "${var.name_prefix}-r53-query-logs"
  destination_arn = aws_s3_bucket.dns_logs.arn
}

resource "aws_route53_resolver_query_log_config_association" "assoc" {
  resolver_query_log_config_id = aws_route53_resolver_query_log_config.this.id
  resource_id = module.vpc.vpc_id
}
