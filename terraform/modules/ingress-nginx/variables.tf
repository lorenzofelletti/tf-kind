variable "namespace" {
  description = "Namespace where the Ingress Nginx controller will be deployed"
  type        = string
  default     = "ingress-nginx"

}

variable "service_account_name" {
  description = "Name of the service account"
  type        = string
  default     = "ingress-nginx"
}

variable "nginx_version" {
  description = "Version of the Ingress Nginx controller"
  type        = string
  default     = "1.12.0-beta.0"
}

variable "additional_controller_args" {
  description = "Additional arguments to pass to the Ingress Nginx controller"
  type        = list(string)
  default     = []
}

variable "controller_image" {
  description = "Image of the Ingress Nginx controller"
  type = object({
    image   = string
    version = string
  })
  default = {
    image   = "registry.k8s.io/ingress-nginx/controller"
    version = "v1.12.0-beta.0@sha256:9724476b928967173d501040631b23ba07f47073999e80e34b120e8db5f234d5"
  }
}

variable "webhook_image" {
  description = "Image of the Ingress Nginx admission webhook"
  type = object({
    image   = string
    version = string
  })
  default = {
    image   = "registry.k8s.io/ingress-nginx/kube-webhook-certgen"
    version = "v1.4.4@sha256:a9f03b34a3cbfbb26d103a14046ab2c5130a80c3d69d526ff8063d2b37b9fd3f"
  }
}

variable "ingress_class_name" {
  description = "Name of the Ingress class"
  type        = string
  default     = "nginx"
}

variable "controller_class" {
  description = "Class of the Ingress controller"
  type        = string
  default     = "k8s.io/ingress-nginx"
}
