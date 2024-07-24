variable "name" {
  description = "The name of the service to expose"
  type        = string
  nullable    = false
}

variable "namespace" {
  description = "The namespace to deploy the resources in"
  type        = string
  default     = "kube-system"
  nullable    = false
}

variable "ports" {
  description = "The ports to expose on the network"
  type        = string
  default     = "1-65535"
  nullable    = false
}

variable "network_gateway" {
  description = "The gateway to use to expose the network"
  type        = string
  default     = null
}

variable "labels" {
  description = "The labels to apply to the network"
  type        = map(string)
  default = {
    "app.kubernetes.io/name"       = "expose-{{NAME}}"
    "app.kubernetes.io/managed-by" = "terraform"
  }
  nullable = false
}

variable "nginx_default_conf" {
  description = "The default nginx configuration (i.e. the value of default.conf key in nginx config map)"
  type        = string
  nullable    = false
  default     = "server { listen 80; }"
}
