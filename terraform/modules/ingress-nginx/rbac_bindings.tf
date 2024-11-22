resource "kubernetes_role_binding_v1" "ingress_nginx" {
  metadata {
    name      = "ingress-nginx"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.controller_labels
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.ingress_nginx.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.ingress_nginx.metadata[0].name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
}

resource "kubernetes_role_binding_v1" "ingress_nginx_admission" {
  metadata {
    name      = "ingress-nginx-admission"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.webhook_labels
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.ingress_nginx_admission.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.ingress_nginx_admission.metadata[0].name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding_v1" "ingress_nginx" {
  metadata {
    name   = "ingress-nginx"
    labels = local.controller_labels
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.ingress_nginx.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.ingress_nginx.metadata[0].name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding_v1" "admission_webhook" {
  metadata {
    name   = "ingress-nginx-admission"
    labels = local.webhook_labels
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.ingress_nginx_admission.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.ingress_nginx_admission.metadata[0].name
    namespace = kubernetes_namespace_v1.this.metadata[0].name
  }
}
