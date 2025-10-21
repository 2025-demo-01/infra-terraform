# EBS 암호화 기본 Active
resource "aws_ebs_encryption_by_default" "on" {
  enabled = true
}

# 모든 S3 Bucket에 Public 접근 차단(계정레벨)
resource "aws_s3_account_public_access_block" "account" {
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# (선택) CloudTrail Log/ALB Access Log용 공통 Log Bucket
resource "aws_s3_bucket" "logs" {
  bucket = "${var.name_prefix}-logs"
  force_destroy = true
  tags = { env = "dev", owner = "sophie", part_of = "exchange" }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logs" {
  bucket = aws_s3_bucket.logs.id
  rule { apply_server_side_encryption_by_default { sse_algorithm = "AES256" } }
}

resource "aws_s3_bucket_versioning" "logs" {
  bucket = aws_s3_bucket.logs.id
  versioning_configuration { status = "Enabled" }
}
