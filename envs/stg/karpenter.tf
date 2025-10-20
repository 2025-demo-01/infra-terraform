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

# EC2NodeClass (stg)
resource "kubectl_manifest" "ec2nodeclass_stg" {
  yaml_body = <<YAML
apiVersion: karpenter.k8s.aws/v1beta1
kind: EC2NodeClass
metadata: { name: ec2nodeclass-stg, namespace: karpenter }
spec:
  amiFamily: AL2023
  role: ${module.eks.nodegroup_role_name}
  subnetSelectorTerms: [ { tags: { karpenter: "enabled" } } ]
  securityGroupSelectorTerms: [ { tags: { karpenter: "enabled" } } ]
  tags: { env: "stg", project: "upx-exchange" }
YAML
}

# NodePool — 일반(Spot 우선)
resource "kubectl_manifest" "nodepool_general_stg" {
  yaml_body = <<YAML
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata: { name: general-stg, namespace: karpenter }
spec:
  template:
    metadata: { labels: { workload: "general" } }
    spec:
      nodeClassRef: { name: ec2nodeclass-stg }
      requirements:
        - key: "karpenter.k8s.aws/instance-category"
          operator: In
          values: ["c","m","r"]
        - key: "karpenter.k8s.aws/capacity-type"
          operator: In
          values: ["spot","on-demand"]
  limits:
    cpu: "1500"
    memory: "3000Gi"
  disruption: { consolidationPolicy: WhenEmpty }
  weight: 10
YAML
}

# NodePool — 저지연(스펙 downscale)
resource "kubectl_manifest" "nodepool_ll_stg" {
  yaml_body = <<YAML
apiVersion: karpenter.sh/v1beta1
kind: NodePool
metadata: { name: ll-stg, namespace: karpenter }
spec:
  template:
    metadata:
      labels:
        workload: "low-latency"
        numa: "aware"
        cpu-manager-policy: "static"
    spec:
      nodeClassRef: { name: ec2nodeclass-stg }
      taints:
        - key: "workload"
          value: "low-latency"
          effect: NoSchedule
      requirements:
        - key: "karpenter.k8s.aws/instance-family"
          operator: In
          values: ["c6i","c7i"]
        - key: "karpenter.k8s.aws/instance-size"
          operator: In
          values: ["2xlarge","4xlarge","8xlarge"]
        - key: "karpenter.k8s.aws/capacity-type"
          operator: In
          values: ["on-demand","spot"]
  limits:
    cpu: "800"
    memory: "1600Gi"
  disruption:
    consolidationPolicy: WhenUnderutilized
    consolidateAfter: 180s
  weight: 20
YAML
}
