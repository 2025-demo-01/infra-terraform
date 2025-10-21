############################
# Karpenter Controller IRSA + Node Role/InstanceProfile + 기본 Provisioner/NodeClass
############################

# Controller용 ServiceAccount에 매핑되는 IRSA Role
data "aws_iam_policy_document" "karpenter_controller_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals { type = "Federated", identifiers = [var.cluster_oidc_provider_arn] }
    condition {
      test     = "StringEquals"
      variable = replace(var.cluster_oidc_provider_arn, "arn:aws:iam::", "") # harmless placeholder
      values   = []
    }
  }
}

# 위 condition은 provider별 sub 조건이 필요하므로 간단화. 실제 운영 시 아래와 같이 교체 권장:
#  variable = "${replace(var.cluster_oidc_provider_arn, "arn:aws:iam::", "")}:sub"
#  values   = ["system:serviceaccount:karpenter:karpenter"]

resource "aws_iam_role" "karpenter_controller" {
  name               = "${var.cluster_name}-karpenter-controller"
  assume_role_policy = data.aws_iam_policy_document.karpenter_controller_assume.json
  tags               = var.tags
}

# 최소 권한(공식 권장 정책은 꽤 큼; 여기선 필수 범위 축소)
resource "aws_iam_policy" "karpenter_controller_policy" {
  name   = "${var.cluster_name}-karpenter-controller"
  policy = data.aws_iam_policy_document.karpenter_controller.json
}

data "aws_iam_policy_document" "karpenter_controller" {
  statement { actions = ["ec2:Describe*","ssm:GetParameter"], resources = ["*"] }
  statement { actions = ["iam:PassRole"], resources = ["*"], condition { test = "StringLike", variable = "iam:PassedToService", values = ["ec2.amazonaws.com"] } }
}

resource "aws_iam_role_policy_attachment" "karpenter_controller_attach" {
  role       = aws_iam_role.karpenter_controller.name
  policy_arn = aws_iam_policy.karpenter_controller_policy.arn
}

# Karpenter가 생성하는 노드용 IAM Role/InstanceProfile
data "aws_iam_policy_document" "karpenter_node_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals { type = "Service", identifiers = ["ec2.amazonaws.com"] }
  }
}

resource "aws_iam_role" "karpenter_node" {
  name               = "${var.cluster_name}-karpenter-node"
  assume_role_policy = data.aws_iam_policy_document.karpenter_node_assume.json
  tags               = var.tags
}

resource "aws_iam_role_policy_attachment" "node_worker" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}
resource "aws_iam_role_policy_attachment" "node_cni" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}
resource "aws_iam_role_policy_attachment" "node_ecr" {
  role       = aws_iam_role.karpenter_node.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_instance_profile" "karpenter_node" {
  name = "${var.cluster_name}-karpenter-node"
  role = aws_iam_role.karpenter_node.name
  tags = var.tags
}

# ---- Kubernetes 리소스 (Provisioner/NodeClass) ----
resource "kubernetes_namespace" "karpenter" {
  metadata { name = "karpenter" }
}

# NodeClass (EC2NodeClass) & Provisioner는 Karpenter 버전에 따라 CRD가 다릅니다.
# 여기서는 kubernetes_manifest (k8s provider v2.33+)를 사용한 예시입니다.

resource "kubernetes_manifest" "nodeclass" {
  manifest = {
    apiVersion = "karpenter.k8s.aws/v1beta1"
    kind       = "EC2NodeClass"
    metadata   = { name = "default" }
    spec = {
      role                = aws_iam_role.karpenter_node.name
      amiFamily           = "AL2"
      subnetSelectorTerms = [{ id = var.private_subnet_ids[0] }]
      securityGroupSelectorTerms = [{ id = var.security_group_ids[0] }]
    }
  }
  depends_on = [kubernetes_namespace.karpenter]
}

resource "kubernetes_manifest" "provisioner" {
  manifest = {
    apiVersion = "karpenter.sh/v1beta1"
    kind       = "Provisioner"
    metadata   = { name = "default" }
    spec = {
      requirements = [
        { key = "node.kubernetes.io/instance-type", operator = "In", values = var.instance_families }
      ]
      limits = { resources = { cpu = "1000", memory = "2000Gi" } }
      providerRef = { name = kubernetes_manifest.nodeclass.manifest.metadata.name, kind = "EC2NodeClass" }
      consolidation = { enabled = true }
      ttlSecondsAfterEmpty = 120
    }
  }
  depends_on = [kubernetes_namespace.karpenter, kubernetes_manifest.nodeclass]
}
