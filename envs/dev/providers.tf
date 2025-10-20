provider "aws" { region = var.region }

data "aws_eks_cluster" "this" {
  depends_on = [module.eks]
  name       = module.eks.cluster_name
}
data "aws_eks_cluster_auth" "this" { name = module.eks.cluster_name }

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
provider "aws" {
  region = var.region
  default_tags {
    tags = var.tags
  }
}
