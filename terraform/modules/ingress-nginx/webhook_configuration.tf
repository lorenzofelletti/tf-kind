resource "kubernetes_validating_webhook_configuration_v1" "ingress_nginx_admission" {
  metadata {
    name   = "ingress-nginx-admission"
    labels = local.webhook_labels
  }
  webhook {
    name                      = "validate.nginx.ingress.kubernetes.io"
    admission_review_versions = ["v1"]
    client_config {
      service {
        name      = kubernetes_service_v1.ingress_nginx_admission.metadata[0].name
        namespace = kubernetes_namespace_v1.this.metadata[0].name
        path      = "/networking/v1/ingresses"
        port      = 443
      }
    }
    failure_policy = "Fail"
    match_policy   = "Equivalent"
    side_effects   = "None"
    rule {
      api_groups   = ["networking.k8s.io"]
      api_versions = ["v1"]
      operations   = ["CREATE", "UPDATE"]
      resources    = ["ingresses"]
    }
  }
}
