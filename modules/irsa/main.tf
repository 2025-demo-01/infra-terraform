############################
# IRSA roles from map(var.roles)
############################

locals {
  # issuer URL → without https://
  oidc_url = chomp(replace(var.cluster_oidc_provider_arn, "arn:aws:iam::", ""))
}

# OIDC provider ARN에서 계정 ID를 뽑아 서브(claim) Condition 구성
data "aws_caller_identity" "current" {}

# 역할별 생성
resource "aws_iam_role" "this" {
  for_each = var.roles
  name     = "${var.cluster_name}-${each.key}"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRoleWithWebIdentity"
      Effect = "Allow"
      Principal = {
        Federated = var.cluster_oidc_provider_arn
      }
      Condition = {
        StringEquals = {
          # 실제 OIDC issuer host/경로 + serviceaccount subject를 써야 함
          # 예: oidc.eks.ap-northeast-2.amazonaws.com/id/XXXX:sub → system:serviceaccount:<ns>:<sa>
          # 여기선 간단 예시:
          # "<issuer-host>:sub" = "system:serviceaccount:${each.value.namespace}:${each.value.service_account}"
        }
      }
    }]
  })

  tags = var.tags
}

# Inline Policy 첨부 (파일에서 로드)
data "local_file" "policy" {
  for_each = var.roles
  filename = each.value.policy_json_path
}

resource "aws_iam_role_policy" "inline" {
  for_each = var.roles
  name     = "${var.cluster_name}-${each.key}"
  role     = aws_iam_role.this[each.key].id
  policy   = data.local_file.policy[each.key].content
}
