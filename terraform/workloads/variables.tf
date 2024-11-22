

### --- Terraform Configuration --- ###

variable "kubeconfig" {
  description = <<-EOT
  Kubeconfig configuration to use. Can be either a local path or a MinIO path to a kubeconfig file.
  Fields:
  - local: Local path to the kubeconfig file
  - remote: Remote path to the kubeconfig file. Must be a MinIO path.
    Fields:
    - bucket_name: The name of the bucket
    - object_name: The name of the object
    - store_locally: Where to store the kubeconfig file locally (default: /tmp/kubeconfig)
  - context_name: The name of the context to use in the kubeconfig file (optional).
  Note: only one of local or remote can be set.
  EOT
  type = object({
    local = optional(object({
      path = string
    }))
    remote = optional(object({
      bucket_name   = string
      object_name   = string
      store_locally = optional(string, "/tmp/kubeconfig")
    }))
    context_name = optional(string)
  })

  validation {
    condition     = provider::logic::xor(var.kubeconfig.local != null, var.kubeconfig.remote != null)
    error_message = "One of local or remote must be set, but not both."
  }

  validation {
    condition     = var.kubeconfig.context_name != ""
    error_message = "context_name must be a non-empty string or null. Got empty string."
  }
}

# Should be optional, but Terraform does not support optional providers
variable "minio_key_file" {
  description = "Path to the file containing the MinIO access key and secret key"
  type        = string
}

variable "minio_server" {
  description = "The MinIO server to use (e.g. localhost:9000)"
  type        = string
  default     = "localhost:9000"
}
