# IRSA: Karpenter Controller
data "aws_iam_policy_document" "karpenter_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals { type = "Federated", identifiers = [aws_iam_openid_connect_provider.eks.arn] }
    condition {
      test     = "StringEquals"
      variable = replace(aws_iam_openid_connect_provider.eks.url, "https://", "") + ":sub"
      values   = ["system:serviceaccount:karpenter:karpenter"]
    }
  }
}
resource "aws_iam_role" "karpenter" {
  name               = "${var.cluster_name}-karpenter"
  assume_role_policy = data.aws_iam_policy_document.karpenter_assume.json
  tags               = var.tags
}
resource "aws_iam_role_policy_attachment" "karpenter_controller" {
  role       = aws_iam_role.karpenter.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}
resource "aws_iam_role_policy_attachment" "karpenter_ssm" {
  role       = aws_iam_role.karpenter.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

# Karpenter 설치
resource "helm_release" "karpenter" {
  name       = "karpenter"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter"
  version    = var.karpenter_version
  namespace  = "karpenter"

  set { name = "settings.clusterName", value = var.cluster_name }
  set { name = "settings.interruptionQueue", value = "${var.cluster_name}-karpenter-int-queue" }
  set { name = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn", value = aws_iam_role.karpenter.arn }
}

# EC2NodeClass — 저지연 풀
resource "kubectl_manifest" "ec2nodeclass_ll" {
  yaml_body = <<YAML
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata: { name: ec2nodeclass-ll, namespace: karpenter }
spec:
  amiFamily: AL2023
  role: ${module.eks.nodegroup_role_name}
  subnetSelectorTerms: [ { tags: { karpenter: "enabled" } } ]
  securityGroupSelectorTerms: [ { tags: { karpenter: "enabled" } } ]
  tags: { workload: "low-latency", env: "prod" }
YAML
}

# EC2NodeClass — 범용(Spot 중심)
resource "kubectl_manifest" "ec2nodeclass_spot" {
  yaml_body = <<YAML
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata: { name: ec2nodeclass-spot, namespace: karpenter }
spec:
  amiFamily: AL2023
  role: ${module.eks.nodegroup_role_name}
  subnetSelectorTerms: [ { tags: { karpenter: "enabled" } } ]
  securityGroupSelectorTerms: [ { tags: { karpenter: "enabled" } } ]
  tags: { workload: "general", env: "prod" }
YAML
}

resource "kubectl_manifest" "ec2nodeclass_ll_bottlerocket" {
  yaml_body = <<YAML
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata: { name: ec2nodeclass-ll-br, namespace: karpenter }
spec:
  amiFamily: Bottlerocket
  role: ${module.eks.nodegroup_role_name}
  subnetSelectorTerms: [ { tags: { karpenter: "enabled" } } ]
  securityGroupSelectorTerms: [ { tags: { karpenter: "enabled" } } ]
  tags: { workload: "low-latency", env: "prod" }
YAML
}




# NodePool — 일반 워크로드 (Spot 우선)
resource "kubectl_manifest" "nodepool_spot_general" {
  yaml_body = <<YAML
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata: { name: spot-general, namespace: karpenter }
spec:
  template:
    metadata:
      labels: { workload: "general" }
    spec:
      nodeClassRef: { name: ec2nodeclass-spot }
      requirements:
        - key: "karpenter.k8s.aws/instance-category"
          operator: In
          values: ["c","m","r"]
        - key: "karpenter.k8s.aws/capacity-type"
          operator: In
          values: ["spot","on-demand"]
  limits:
    cpu: "4000"
    memory: "8192Gi"
  disruption:
    consolidationPolicy: WhenEmpty
  weight: 10
YAML
}
