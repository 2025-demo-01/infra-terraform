locals {
  tags = merge({
    "project" = "upx-exchange"
    "owner"   = "platform"
  }, var.tags)
}

resource "aws_eks_cluster" "this" {
  name     = var.cluster_name
  role_arn = aws_iam_role.cluster.arn
  version  = var.kubernetes_version

  vpc_config {
    subnet_ids              = concat(var.private_subnet_ids, var.public_subnet_ids)
    endpoint_private_access = true
    endpoint_public_access  = true
  }

  tags = local.tags
}

resource "aws_iam_role" "cluster" {
  name               = "${var.cluster_name}-cluster-role"
  assume_role_policy = data.aws_iam_policy_document.cluster_assume.json
  tags               = local.tags
}
data "aws_iam_policy_document" "cluster_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service", identifiers = ["eks.amazonaws.com"] }
  }
}
resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  role       = aws_iam_role.cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# 시스템 워커(관리형 노드그룹) — 시스템 파드/애드온 전용, 온디맨드
resource "aws_eks_node_group" "system" {
  cluster_name    = aws_eks_cluster.this.name
  node_group_name = "system-ng"
  node_role_arn   = aws_iam_role.ng.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = var.system_instance_types
  capacity_type   = "ON_DEMAND"
  scaling_config {
    min_size     = var.system_min_size
    max_size     = var.system_max_size
    desired_size = var.system_min_size
  }
  ami_type = "AL2_x86_64" # Bottlerocket 선호 시 변경 가능
  labels = {
    "workload" = "system"
  }
  taint {
    key    = "workload"
    value  = "system"
    effect = "NO_SCHEDULE"
  }
  tags = local.tags
}

resource "aws_iam_role" "ng" {
  name               = "${var.cluster_name}-nodegroup-role"
  assume_role_policy = data.aws_iam_policy_document.ng_assume.json
  tags               = local.tags
}
data "aws_iam_policy_document" "ng_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service", identifiers = ["ec2.amazonaws.com"] }
  }
}
resource "aws_iam_role_policy_attachment" "ng_worker" {
  role       = aws_iam_role.ng.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "ng_cni" {
  role       = aws_iam_role.ng.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
resource "aws_iam_role_policy_attachment" "ng_ecr" {
  role       = aws_iam_role.ng.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

output "cluster_id"    { value = aws_eks_cluster.this.id }
output "cluster_name"  { value = aws_eks_cluster.this.name }
output "cluster_arn"   { value = aws_eks_cluster.this.arn }
output "cluster_endpoint" { value = aws_eks_cluster.this.endpoint }
output "cluster_ca"    { value = aws_eks_cluster.this.certificate_authority[0].data }
