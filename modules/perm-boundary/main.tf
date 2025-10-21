data "aws_iam_policy_document" "boundary" {
  statement {
    sid = "DenyOutsideTaggedEnv"
    effect = "Deny"
    actions = ["*"]
    resources = ["*"]
    condition {
      test     = "StringNotEquals"
      variable = "aws:RequestTag/env"
      values   = [lookup(var.allowed_tags, "env", "dev")]
    }
  }
}
resource "aws_iam_policy" "boundary" {
  name   = var.name
  policy = data.aws_iam_policy_document.boundary.json
}
output "policy_arn" { value = aws_iam_policy.boundary.arn }
