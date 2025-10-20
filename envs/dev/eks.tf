resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = ["9e99a48a9960b14926bb7f3b02e22da2b0ab7280"]
  url             = "https://oidc.eks.${var.region}.amazonaws.com/id/sophielog-dev"
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
  kms_key_arn         = module.kms.eks_kms_arn
  system_instance_types = ["m6i.large"]
  system_min_size       = 1
  system_max_size       = 2

  tags = var.tags
}
