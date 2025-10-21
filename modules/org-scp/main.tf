resource "aws_organizations_policy" "scp" {
  name        = var.policy_name
  description = "Baseline guardrails"
  type        = "SERVICE_CONTROL_POLICY"
  content     = var.content_json
}
