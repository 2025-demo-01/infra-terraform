locals {
  scp = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Sid="DenyS3Public", Effect="Deny",
        Action=["s3:PutBucketPublicAccessBlock","s3:PutBucketAcl","s3:PutBucketPolicy","s3:PutObjectAcl"],
        Resource="*", Condition={ Bool={ "aws:ViaAWSService":"false" } } },
      { Sid="RequireIMDSv2", Effect="Deny",
        Action="ec2:ModifyInstanceMetadataOptions", Resource="*",
        Condition={ StringNotEquals={ "ec2:MetadataHttpTokens":"required" } } },
      { Sid="DenyDisableSecurityServices", Effect="Deny",
        Action=[ "guardduty:*Disable*","cloudtrail:StopLogging","securityhub:Disable*","route53-recovery-control-config:Delete*" ],
        Resource="*" }
    ]
  })
}
module "org_scp" {
  source       = "../../modules/org-scp"
  policy_name  = "baseline-guardrails"
  content_json = local.scp
}
