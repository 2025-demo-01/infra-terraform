resource "helm_release" "opencost" {
  name             = "opencost"
  repository       = "https://opencost.github.io/opencost-helm-chart"
  chart            = "opencost"
  namespace        = var.namespace
  create_namespace = true

  set { name = "opencost.productMetricsEnabled", value = "true" }
  set { name = "opencost.kubeClusterName", value = var.cluster_name }
  set { name = "opencost.currencyCode", value = var.currency }
}
