variable "cluster_spec" {
  description = "Specs of the cluster"
  type = object({
    name                      = optional(string, "cluster")
    k8s_version               = string
    wait_for_ready            = optional(bool, true)
    containerd_config_patches = optional(list(string), [])
    nodes = optional(map(object({
      role                   = optional(string, "worker")
      kubeadm_config_patches = optional(list(string), [])
      extra_port_mappings = optional(object({
        container_port = optional(number)
        host_port      = optional(number)
        listen_address = optional(string)
        protocol       = optional(string)
      }))
    })), {})
    networking = optional(object({
      apiserver_port      = optional(number, null)
      disable_default_cni = optional(bool, null)
      install_calico      = optional(bool, false)
      ip_family           = optional(string, null)
      pod_subnet          = optional(string, null)
      service_subnet      = optional(string, null)
    }), null)
  })
  default = {
    k8s_version = "1.30.0"
  }

  nullable = false

  validation {
    condition     = can(regex("\\d\\.\\d{1,3}.\\d{1,3}", var.cluster_spec.k8s_version))
    error_message = "cluster_spec.k8s_version don't match regex `\\d\\.\\d{1,3}.\\d{1,3}`"
  }

  validation {
    condition     = alltrue([for node in values(var.cluster_spec.nodes) : contains(["control-plane", "worker"], node.role)])
    error_message = "cluster_spec.nodes[*].role should be either `control-plane` or `worker`"
  }

  validation {
    condition     = try(var.cluster_spec.networking.apiserver_port >= 0 && var.cluster_spec.networking.apiserver_port <= 65535, true)
    error_message = "cluster_spec.networking.apiserver_port must be a number between 0 and 65535"
  }

  validation {
    condition     = try(contains(["ipv4", "ipv6", "dual"], var.cluster_spec.networking.ip_family), true)
    error_message = "cluster_spec.networking.ip_family must be either `ipv4`, `ipv6` or `dual`"
  }

  validation {
    condition = (
      try(
        can(regex("^(?:\\d{1,3}\\.){3}\\d{1,3}/\\d{1,2}$", var.cluster_spec.networking.pod_subnet)),
        var.cluster_spec.networking.ip_family != "ipv4",
        false
      ) ||
      var.cluster_spec.networking == null || try(lookup(var.cluster_spec.networking, "pod_subnet", null), null) == null
    )
    error_message = "cluster_spec.networking.ip_family is `ipv4` but cluster_spec.networking.pod_subnet is not a valid CIDR"
  }

  validation {
    condition = (
      try(
        can(regex("^(?:\\d{1,3}\\.){3}\\d{1,3}/\\d{1,2}$", var.cluster_spec.networking.service_subnet)),
        var.cluster_spec.networking.ip_family != "ipv4",
        false
      ) ||
      var.cluster_spec.networking == null || try(lookup(var.cluster_spec.networking, "service_subnet", null), null) == null
    )
    error_message = "cluster_spec.networking.ip_family is `ipv4` but cluster_spec.networking.service_subnet is not a valid CIDR"
  }

  validation {
    condition     = try(!var.cluster_spec.networking.install_calico || var.cluster_spec.networking.disable_default_cni, true)
    error_message = "cluster_spec.networking.install_calico is `true` but cluster_spec.networking.disable_default_cni is `false`"
  }
}

variable "calico_version" {
  description = "The version of Calico to install, if you chose to install Calico in the cluster"
  type        = string
  default     = null

  validation {
    condition     = var.calico_version == null || can(regex("^v(\\d{1,3}\\.){2}\\d{1,3}$", var.calico_version))
    error_message = "calico_version should match regex `^v(\\d{1,3}\\.){2}\\d{1,3}$`"
  }

  validation {
    condition     = var.calico_version == null || try(var.cluster_spec.networking.install_calico, false)
    error_message = "cluster_spec.networking.install_calico must be `true` if calico_version is not `null`"
  }

  validation {
    condition     = try(var.cluster_spec.networking.install_calico, false) ? var.calico_version != null : true
    error_message = "calico_version cannot be `null` if cluster_spec.networking.install_calico is `true`"
  }
}

variable "expose_minio_in_cluster" {
  description = <<-EOT
  Expose MinIO in the cluster
  Fields:
  - enabled: Enable exposing MinIO in the cluster
  - gateway: The gateway to use to expose MinIO in the cluster
  - network: The network to use to expose MinIO in the cluster.
  Either gateway or network must be set. If network is set, Terraform will try to find the gateway automatically.
  EOT
  type = object({
    enabled = optional(bool, false)
    gateway = optional(string)
    network = optional(string)
  })
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
  nullable    = false
}

variable "minio_key_file" {
  description = "Path to the file containing the MinIO access key and secret key"
  type        = string
}

variable "minio_server" {
  description = "The MinIO server to use"
  type        = string
  default     = "localhost:9000"
}

variable "kubeconfig_upload_bucket_name" {
  description = "The name of the bucket to upload the kubeconfig to. If not set, the kubeconfig will not be uploaded."
  type        = string
}
