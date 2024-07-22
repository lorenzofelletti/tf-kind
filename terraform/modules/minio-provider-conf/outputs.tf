output "configuration" {
  description = "Configuration for the Minio provider. Pass each field to the provider."
  value       = local.minio_credentials
  sensitive   = true
}
