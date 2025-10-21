output "provisioner_names" {
  value = [for p in kubernetes_manifest.provisioner : p.manifest.metadata.name]
}
