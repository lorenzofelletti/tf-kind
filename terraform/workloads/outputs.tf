output "minio_kubernetes_service" {
  description = "Kubernetes service exposing MinIO"
  value       = try(module.expose-minio[0].service, null)
}