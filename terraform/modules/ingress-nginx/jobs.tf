resource "kubernetes_job_v1" "ingress_nginx_admission_create" {
  metadata {
    name      = "ingress-nginx-admission-create"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.webhook_labels
  }
  spec {
    template {
      metadata {
        name   = "ingress-nginx-admission-create"
        labels = local.webhook_labels
      }
      spec {
        container {
          name              = "create"
          image             = "${var.webhook_image.image}:${var.webhook_image.version}"
          image_pull_policy = "IfNotPresent"
          args = [
            "create",
            "--namespace=$(POD_NAMESPACE)",
            "--host=ingress-nginx-controller-admission,ingress-nginx-controller-admission.$(POD_NAMESPACE).svc",
            # "--host=ingress-nginx-admission,ingress-nginx-admission.$(POD_NAMESPACE).svc",
            "--secret-name=ingress-nginx-admission",
          ]
          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref { field_path = "metadata.namespace" }
            }
          }
          security_context {
            allow_privilege_escalation = false
            capabilities {
              drop = ["ALL"]
            }
            read_only_root_filesystem = true
            run_as_group              = 65532
            run_as_non_root           = true
            run_as_user               = 65532
            seccomp_profile { type = "RuntimeDefault" }
          }
        }
        node_selector        = { "kubernetes.io/os" = "linux" }
        restart_policy       = "OnFailure"
        service_account_name = kubernetes_service_account_v1.ingress_nginx_admission.metadata[0].name
      }
    }
  }
}

resource "kubernetes_job_v1" "ingress_nginx_admission_patch" {
  metadata {
    name      = "ingress-nginx-admission-patch"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.webhook_labels
  }
  spec {
    template {
      metadata {
        name   = "ingress-nginx-admission-patch"
        labels = local.webhook_labels
      }
      spec {
        container {
          name              = "patch"
          image             = "${var.webhook_image.image}:${var.webhook_image.version}"
          image_pull_policy = "IfNotPresent"
          args = [
            "patch",
            "--webhook-name=ingress-nginx-admission",
            "--namespace=$(POD_NAMESPACE)",
            "--patch-mutating=false",
            "--secret-name=ingress-nginx-admission",
            "--patch-failure-policy=Fail",
          ]
          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref { field_path = "metadata.namespace" }
            }
          }
          security_context {
            allow_privilege_escalation = false
            capabilities {
              drop = ["ALL"]
            }
            read_only_root_filesystem = true
            run_as_group              = 65532
            run_as_non_root           = true
            run_as_user               = 65532
            seccomp_profile { type = "RuntimeDefault" }
          }
        }
        node_selector        = { "kubernetes.io/os" : "linux" }
        restart_policy       = "OnFailure"
        service_account_name = kubernetes_service_account_v1.ingress_nginx_admission.metadata[0].name
      }
    }
  }
}