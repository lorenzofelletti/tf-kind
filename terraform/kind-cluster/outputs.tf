output "kubeconfig" {
  description = "Kubeconfig file for the cluster"
  value       = kind_cluster.this.kubeconfig
  sensitive   = true
}

output "cluster_provider" {
  description = "Provider of the cluster"
  value       = "local"
}
