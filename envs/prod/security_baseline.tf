resource "aws_guardduty_detector" "this" { enable = true }

resource "aws_securityhub_account" "this" {}
resource "aws_securityhub_standards_subscription" "cis" {
  standards_arn = "arn:aws:securityhub:::ruleset/cis-aws-foundations-benchmark/v/1.4.0"
}
resource "aws_securityhub_standards_subscription" "fsbp" {
  standards_arn = "arn:aws:securityhub:::ruleset/aws-foundational-security-best-practices/v/1.0.0"

}
