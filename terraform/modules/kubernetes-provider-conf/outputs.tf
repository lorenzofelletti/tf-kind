output "configuration" {
  description = "Configuration for the Kubernetes and/or Helm provider. Pass each field to the provider."
  value       = local.kube_conf
}
