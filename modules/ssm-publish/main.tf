resource "aws_ssm_parameter" "p" {
  for_each = var.kv
  name  = "${var.path_prefix}/${each.key}"
  type  = "String"
  value = each.value
}
