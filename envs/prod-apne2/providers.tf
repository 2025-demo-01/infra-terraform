provider "aws" {
  region = var.region
}

data "aws_eks_cluster" "this" {
  depends_on = [module.eks] # 초기에는 존재하지 않을 수 있어 별도 사용 시 분기 필요
  name       = module.eks.cluster_name
}

data "aws_eks_cluster_auth" "this" {
  name = module.eks.cluster_name
}

provider "kubernetes" {
  host                   = try(module.eks.cluster_endpoint, "")
  cluster_ca_certificate = base64decode(try(module.eks.cluster_ca, ""))
  token                  = data.aws_eks_cluster_auth.this.token
}

provider "helm" {
  kubernetes {
    host                   = try(module.eks.cluster_endpoint, "")
    cluster_ca_certificate = base64decode(try(module.eks.cluster_ca, ""))
    token                  = data.aws_eks_cluster_auth.this.token
  }
}

provider "kubectl" {
  host                   = try(module.eks.cluster_endpoint, "")
  cluster_ca_certificate = base64decode(try(module.eks.cluster_ca, ""))
  token                  = data.aws_eks_cluster_auth.this.token
  load_config_file       = false
}
