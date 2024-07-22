variable "name_template" {
  description = "The template for the deployment/service name"
  type        = string
  default     = "expose-{{NET_NAME}}"
  nullable    = false
}

variable "network_name" {
  description = "The name of the network"
  type        = string
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
    "app.kubernetes.io/name"       = "expose-{{NET_NAME}}-network"
    "app.kubernetes.io/managed-by" = "terraform"
  }
  nullable = false
}
