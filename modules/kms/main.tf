resource "aws_kms_key" "this" {
  description             = "${var.name_prefix} master key"
  deletion_window_in_days = 7
  enable_key_rotation     = var.rotation
  multi_region            = false
  tags                    = var.tags
}
resource "aws_kms_alias" "alias" {
  name          = "alias/${var.name_prefix}"
  target_key_id = aws_kms_key.this.key_id
}
