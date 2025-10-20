# ALB Controller IRSA
module "alb_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39"
  role_name = "${var.cluster_name}-alb-sa"
  attach_load_balancer_controller_policy = true
  oidc_providers = {
    ex = {
      provider_arn               = aws_iam_openid_connect_provider.eks.arn
      namespace_service_accounts = ["kube-system:aws-load-balancer-controller"]
    }
  }
  tags = var.tags
}

resource "helm_release" "alb" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  set { name = "clusterName", value = var.cluster_name }
  set { name = "serviceAccount.create", value = "true" }
  set { name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn", value = module.alb_irsa.iam_role_arn }
}

# EBS CSI IRSA
module "ebs_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39"
  role_name             = "${var.cluster_name}-ebs-csi"
  attach_ebs_csi_policy = true
  oidc_providers = {
    ex = {
      provider_arn               = aws_iam_openid_connect_provider.eks.arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }
  tags = var.tags
}

resource "helm_release" "ebs_csi" {
  name       = "aws-ebs-csi-driver"
  repository = "https://kubernetes-sigs.github.io/aws-ebs-csi-driver"
  chart      = "aws-ebs-csi-driver"
  namespace  = "kube-system"
  set { name = "controller.serviceAccount.create", value = "true" }
  set { name = "controller.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn", value = module.ebs_irsa.iam_role_arn }
}

# ExternalDNS IRSA
module "externaldns_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.39"
  role_name = "${var.cluster_name}-externaldns"
  attach_external_dns_policy = true
  oidc_providers = {
    ex = {
      provider_arn               = aws_iam_openid_connect_provider.eks.arn
      namespace_service_accounts = ["kube-system:external-dns"]
    }
  }
  tags = var.tags
}

resource "helm_release" "external_dns" {
  name       = "external-dns"
  repository = "https://kubernetes-sigs.github.io/external-dns"
  chart      = "external-dns"
  namespace  = "kube-system"
  set { name = "provider", value = "aws" }
  set { name = "policy", value = "sync" }
  set { name = "serviceAccount.create", value = "true" }
  set { name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn", value = module.externaldns_irsa.iam_role_arn }
  set { name = "domainFilters[0]", value = var.domain_root }
}

# Metrics Server
resource "helm_release" "metrics_server" {
  name       = "metrics-server"
  repository = "https://kubernetes-sigs.github.io/metrics-server/"
  chart      = "metrics-server"
  namespace  = "kube-system"
}
