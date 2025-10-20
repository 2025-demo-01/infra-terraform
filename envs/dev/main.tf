resource "kubectl_manifest" "namespaces" {
  yaml_body = <<YAML
apiVersion: v1
kind: Namespace
metadata: { name: "kube-system" }
---
apiVersion: v1
kind: Namespace
metadata: { name: "karpenter" }
---
apiVersion: v1
kind: Namespace
metadata: { name: "observability" }
---
apiVersion: v1
kind: Namespace
metadata: { name: "matching" }
---
apiVersion: v1
kind: Namespace
metadata: { name: "trading" }
---
apiVersion: v1
kind: Namespace
metadata: { name: "wallet" }
---
apiVersion: v1
kind: Namespace
metadata: { name: "risk" }
---
apiVersion: v1
kind: Namespace
metadata: { name: "opencost" }
YAML
}
