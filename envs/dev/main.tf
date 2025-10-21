locals {
  tags = {
    env     = "dev"
    owner   = "sophie"
    part_of = "exchange"
  }
}

module "vpc" {
  source          = "../../modules/vpc"
  name_prefix     = var.name_prefix
  cidr_block      = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  tags            = local.tags
}

module "eks" {
  source              = "../../modules/eks"
  name_prefix         = var.name_prefix
  version             = var.eks_version
  vpc_id              = module.vpc.vpc_id
  private_subnet_ids  = module.vpc.private_subnet_ids
  public_subnet_ids   = module.vpc.public_subnet_ids
  node_instance_types = var.node_instance_types
  tags                = local.tags
}

module "karpenter" {
  source                     = "../../modules/karpenter"
  cluster_name               = module.eks.cluster_name
  cluster_oidc_provider_arn  = module.eks.oidc_provider_arn
  private_subnet_ids         = module.vpc.private_subnet_ids
  security_group_ids         = [module.eks.cluster_security_group_id]
  instance_families          = var.karpenter_instance_families
  tags                       = local.tags
}

module "irsa" {
  source                    = "../../modules/irsa"
  cluster_name              = module.eks.cluster_name
  cluster_oidc_provider_arn = module.eks.oidc_provider_arn
  roles = {
    external_dns = {
      namespace        = "kube-system"
      service_account  = "external-dns"
      policy_json_path = "${path.module}/policies/external-dns.json"
    }
    alb_controller = {
      namespace        = "kube-system"
      service_account  = "aws-load-balancer-controller"
      policy_json_path = "${path.module}/policies/aws-lb-controller.json"
    }
  }
  tags = local.tags
}

module "msk" {
  source         = "../../modules/msk"
  name_prefix    = var.name_prefix
  vpc_id         = module.vpc.vpc_id
  subnet_ids     = module.vpc.private_subnet_ids
  kafka_version  = var.msk_kafka_version
  tags           = local.tags
}

module "kms" {
  source      = "../../modules/kms"
  name_prefix = var.name_prefix
  tags        = local.tags
}

resource "aws_eks_cluster" "encryption_patch" {
  name = module.eks.cluster_name
  encryption_config {
    resources = ["secrets"]
    provider { key_arn = module.kms.key_arn }
  }
  depends_on = [module.kms]
  lifecycle { ignore_changes = all } 
}


module "aurora" {
  source            = "../../modules/aurora"
  name_prefix       = var.name_prefix
  engine            = var.aurora_engine
  engine_version    = var.aurora_engine_version
  instance_class    = var.aurora_instance_class
  subnet_ids        = module.vpc.private_subnet_ids
  vpc_id            = module.vpc.vpc_id
  tags              = local.tags
}

module "clickhouse" {
  source                = "../../modules/clickhouse"
  name_prefix           = var.name_prefix
  admin_username        = var.clickhouse_admin_username
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  tags                  = local.tags
}

module "route53" {
  source         = "../../modules/route53"
  root_domain    = "sophie.exchange" # 예시
  failover_enable = true
  tags           = local.tags
}
