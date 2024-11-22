locals {
  labels = {
    "app.kubernetes.io/name"       = "ingress-nginx"
    "app.kubernetes.io/instance"   = var.namespace
    "app.kubernetes.io/managed-by" = "terraform"
  }
  controller_labels = merge(local.labels, {
    "app.kubernetes.io/component" = "controller"
    "app.kubernetes.io/part-of"   = "ingress-nginx"
    "app.kubernetes.io/version"   = var.nginx_version
  })
  webhook_labels = merge(local.labels, {
    "app.kubernetes.io/component" = "admission-webhook"
    "app.kubernetes.io/part-of"   = "ingress-nginx"
    "app.kubernetes.io/version"   = var.nginx_version
  })
  controller_selector_labels = {
    "app.kubernetes.io/component" = local.controller_labels["app.kubernetes.io/component"]
    "app.kubernetes.io/instance"  = local.controller_labels["app.kubernetes.io/instance"]
    "app.kubernetes.io/name"      = local.controller_labels["app.kubernetes.io/name"]
  }
}
