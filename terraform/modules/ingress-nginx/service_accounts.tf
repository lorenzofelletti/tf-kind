resource "kubernetes_service_account_v1" "ingress_nginx" {
  metadata {
    name      = var.service_account_name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.controller_labels
  }
  automount_service_account_token = true
}

resource "kubernetes_service_account_v1" "ingress_nginx_admission" {
  metadata {
    name      = "${var.service_account_name}-admission"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.controller_labels
  }
  automount_service_account_token = true
}
