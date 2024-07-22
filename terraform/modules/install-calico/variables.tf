variable "calico_version" {
  description = "The version of Calico to install"
  type        = string
  default     = "v3.28.0"
  nullable    = false

  validation {
    condition     = can(regex("^v(\\d{1,3}\\.){2}\\d{1,3}$", var.calico_version))
    error_message = "calico_version should match regex `^v(\\d{1,3}\\.){2}\\d{1,3}$`"
  }
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
}

variable "kubeconfig_context" {
  description = "Kubeconfig context to use"
  type        = string
}

variable "manifest_url_template" {
  description = <<-EOT
  Default should be fine.
  URL template for the Calico manifests. Template the Calico version with `{{CALICO_VERSION}}`.
  The templated version would be replaced with the value of `calico_version` variable.
  EOT
  type = object({
    tigera_operator  = string
    custom_resources = string
  })
  default = {
    tigera_operator  = "https://raw.githubusercontent.com/projectcalico/calico/{{CALICO_VERSION}}/manifests/tigera-operator.yaml"
    custom_resources = "https://raw.githubusercontent.com/projectcalico/calico/{{CALICO_VERSION}}/manifests/custom-resources.yaml"
  }
  nullable = false
}

variable "additional_replace_trigger" {
  description = "Additional triggers to replace the manifests"
  type        = list(string)
  default     = []
  nullable    = false
}
