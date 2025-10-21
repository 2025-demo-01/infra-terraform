provider "aws" {
  region = var.region
}

# (선택) EKS Cluster 생성 후 kubeconfig로 사용
provider "kubernetes" {
  host                   = module.eks.cluster_endpoint
  cluster_ca_certificate = base64decode(module.eks.cluster_certificate_authority_data)
  token                  = data.aws_eks_cluster_auth.this.token
}

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}
