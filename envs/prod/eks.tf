# EKS OIDC (IRSA용) — 실제 계정의 OIDC URL로 조정 필요
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  # 샘플 Thumbprint. 실제 값은 계정/리전에 맞게 업데이트 권장
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
  url             = "https://oidc.eks.${var.region}.amazonaws.com/id/sophielog-prod"
}

module "eks" {
  source              = "../../modules/eks"
  cluster_name        = var.cluster_name
  region              = var.region
  vpc_id              = var.vpc_id
  private_subnet_ids  = module.network.private_subnet_ids
  public_subnet_ids   = module.network.public_subnet_ids
  kubernetes_version  = var.kubernetes_version
  oidc_provider_arn   = aws_iam_openid_connect_provider.eks.arn

  # 시스템 파드 전용 MNG 사이즈/타입
  system_instance_types = ["m6i.large"]
  system_min_size       = 2
  system_max_size       = 6

  tags = var.tags
}
