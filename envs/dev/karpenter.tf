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

# dev: 비용 최소화 — spot-only, 작은 사이즈
resource "kubectl_manifest" "ec2nodeclass_dev" {
  yaml_body = <<YAML
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata: { name: ec2nodeclass-dev, namespace: karpenter }
spec:
  amiFamily: AL2023
  role: ${module.eks.nodegroup_role_name}
  subnetSelectorTerms: [ { tags: { karpenter: "enabled" } } ]
  securityGroupSelectorTerms: [ { tags: { karpenter: "enabled" } } ]
  tags: { env: "dev", project: "upx-exchange" }
YAML
}

resource "kubectl_manifest" "nodepool_dev_spot" {
  yaml_body = <<YAML
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata: { name: dev-spot, namespace: karpenter }
spec:
  template:
    metadata: { labels: { workload: "general" } }
    spec:
      nodeClassRef: { name: ec2nodeclass-dev }
      requirements:
        - key: "karpenter.k8s.aws/instance-category"
          operator: In
          values: ["c","m"]
        - key: "karpenter.k8s.aws/instance-size"
          operator: In
          values: ["large","xlarge","2xlarge"]
        - key: "karpenter.k8s.aws/capacity-type"
          operator: In
          values: ["spot"]
  limits:
    cpu: "300"
    memory: "600Gi"
  disruption:
    consolidationPolicy: WhenEmpty
  weight: 5
YAML
}
