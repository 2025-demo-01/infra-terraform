# 요구: helm/kubernetes providers 구성은 env에서 제공
locals {
  release_name = "clickhouse-operator"
}

resource "helm_release" "operator" {
  name       = local.release_name
  repository = "https://clickhouse-operator.github.io/helm-charts/"
  chart      = "altinity-clickhouse-operator"
  namespace  = var.namespace
  create_namespace = true
}

# 간단한 CHI (ClickHouseInstallation)
resource "kubectl_manifest" "chi" {
  yaml_body = <<YAML
apiVersion: clickhouse.altinity.com/v1
kind: ClickHouseInstallation
metadata:
  name: exchange-ch
  namespace: ${var.namespace}
spec:
  configuration:
    clusters:
      - name: ch1
        layout:
          shardsCount: 1
          replicasCount: ${var.replicas}
        templates:
          podTemplate:
            name: ch-pod
            spec:
              containers:
                - name: clickhouse
                  image: clickhouse/clickhouse-server:23.11
                  volumeMounts:
                    - name: ch-data
                      mountPath: /var/lib/clickhouse
        volumeClaimTemplates:
          - name: ch-data
            spec:
              accessModes: [ "ReadWriteOnce" ]
              resources:
                requests:
                  storage: ${var.storage_size}
YAML
}
