output "web_acl_arn" { value = aws_wafv2_web_acl.this.arn }
output "log_bucket_name" {
  value = coalesce(var.log_bucket_name, try(aws_s3_bucket.waf_logs[0].id, null))
}
