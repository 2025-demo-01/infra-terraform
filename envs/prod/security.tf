# envs/prod/security.tf (예시)
resource "aws_config_configuration_recorder" "main" {
  name     = "default"
  role_arn = aws_iam_role.config.arn
}
# + delivery channel, conformance packs 등
