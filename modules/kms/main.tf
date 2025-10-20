locals {
  tags = merge({
    project = "upx-exchange"
    owner   = "security"
  }, var.tags)
}

resource "aws_kms_key" "this" {
  description             = "SOPS/Secrets key"
  deletion_window_in_days = 7
  enable_key_rotation     = true
  tags                    = local.tags
}

resource "aws_kms_alias" "this" {
  name          = var.alias
  target_key_id = aws_kms_key.this.id
}
