data "aws_iam_openid_connect_provider" "eks" {
  arn = aws_iam_openid_connect_provider.eks.arn
}

# OIDC 공급자 (필요 시 생성)
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"] # 예시
  url             = "https://oidc.eks.${var.region}.amazonaws.com/id/sophielog" # 데모 값
}

module "eks" {
  source              = "../../modules/eks"
  cluster_name        = var.cluster_name
  region              = var.region
  vpc_id              = var.vpc_id
  private_subnet_ids  = var.private_subnet_ids
  public_subnet_ids   = var.public_subnet_ids
  kubernetes_version  = var.kubernetes_version
  oidc_provider_arn   = aws_iam_openid_connect_provider.eks.arn
  tags                = var.tags
}

# 네임스페이스
resource "kubectl_manifest" "namespaces" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata: { name: "kube-system" }
---
apiVersion: v1
kind: Namespace
metadata: { name: "karpenter" }
---
apiVersion: v1
kind: Namespace
metadata: { name: "observability" }
---
apiVersion: v1
kind: Namespace
metadata: { name: "matching" }
---
apiVersion: v1
kind: Namespace
metadata: { name: "trading" }
---
apiVersion: v1
kind: Namespace
metadata: { name: "wallet" }
---
apiVersion: v1
kind: Namespace
metadata: { name: "risk" }
YAML
}
