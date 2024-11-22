resource "kubernetes_namespace_v1" "this" {
  metadata {
    name   = var.namespace
    labels = local.labels
  }
}

resource "kubernetes_config_map_v1" "ingress_nginx_controller" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.controller_labels
  }
  data = null
}

resource "kubernetes_service_v1" "ingress_nginx_controller" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.controller_labels
  }
  spec {
    type             = "NodePort"
    ip_families      = ["IPv4"]
    ip_family_policy = "SingleStack"
    port {
      app_protocol = "http"
      name         = "http"
      port         = 80
      protocol     = "TCP"
    }
    port {
      app_protocol = "https"
      name         = "https"
      port         = 443
      protocol     = "TCP"
    }
    selector = local.controller_selector_labels
  }
}

resource "kubernetes_service_v1" "ingress_nginx_admission" {
  metadata {
    name      = "ingress-nginx-controller-admission"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.controller_labels
  }
  spec {
    type = "ClusterIP"
    port {
      app_protocol = "https"
      name         = "https-webhook"
      port         = 443
      target_port  = "webhook"
    }
    selector = local.controller_selector_labels
  }
}

resource "kubernetes_deployment_v1" "ingress_nginx_controller" {
  metadata {
    name      = "ingress-nginx-controller"
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    labels    = local.controller_labels
  }
  spec {
    min_ready_seconds      = 0
    revision_history_limit = 10
    selector {
      match_labels = local.controller_selector_labels
    }
    strategy {
      rolling_update {
        max_unavailable = 1
      }
    }
    template {
      metadata {
        labels = local.controller_labels
      }
      spec {
        container {
          name              = "controller"
          image             = "${var.controller_image.image}:${var.controller_image.version}"
          image_pull_policy = "IfNotPresent"
          args = concat([
            "/nginx-ingress-controller",
            "--election-id=ingress-controller-leader",
            "--controller-class=${var.controller_class}",
            "ingress-class=nginx",
            "--configmap=$(POD_NAMESPACE)/${kubernetes_config_map_v1.ingress_nginx_controller.metadata[0].name}",
            "--validating-webhook=:8443",
            "--validating-webhook-certificate=/usr/local/certificates/cert",
            "--validating-webhook-key=/usr/local/certificates/key",
            "--watch-ingress-without-class=true",
            "--publish-status-address=localhost",
          ], var.additional_controller_args)
          env {
            name = "POD_NAME"
            value_from {
              field_ref { field_path = "metadata.name" }
            }
          }
          env {
            name = "POD_NAMESPACE"
            value_from {
              field_ref { field_path = "metadata.namespace" }
            }
          }
          env {
            name  = "LD_PRELOAD"
            value = "/usr/local/lib/libmimalloc.so"
          }
          lifecycle {
            pre_stop {
              exec { command = ["/wait-shutdown"] }
            }
          }
          liveness_probe {
            failure_threshold = 5
            http_get {
              path   = "/healthz"
              port   = 10254
              scheme = "HTTP"
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 1
          }
          readiness_probe {
            failure_threshold = 3
            http_get {
              path   = "/healthz"
              port   = 10254
              scheme = "HTTP"
            }
            initial_delay_seconds = 10
            period_seconds        = 10
            success_threshold     = 1
            timeout_seconds       = 1
          }
          port {
            container_port = 80
            host_port      = 80
            name           = "http"
            protocol       = "TCP"
          }
          port {
            container_port = 443
            host_port      = 443
            name           = "https"
            protocol       = "TCP"
          }
          port {
            container_port = 8443
            name           = "webhook"
            protocol       = "TCP"
          }
          resources {
            requests = {
              cpu    = "100m"
              memory = "90Mi"
            }
          }
          security_context {
            allow_privilege_escalation = false
            capabilities {
              add  = ["NET_BIND_SERVICE"]
              drop = ["ALL"]
            }
            read_only_root_filesystem = false
            run_as_group              = 82
            run_as_non_root           = true
            run_as_user               = 101
            seccomp_profile { type = "RuntimeDefault" }
          }
          volume_mount {
            mount_path = "/usr/local/certificates"
            name       = "webhook-cert"
            read_only  = true
          }
        }
        dns_policy = "ClusterFirst"
        node_selector = {
          ingress-ready : "true"
          "kubernetes.io/os" : "linux"
        }
        service_account_name             = kubernetes_service_account_v1.ingress_nginx.metadata[0].name
        termination_grace_period_seconds = 0

        volume {
          name = "webhook-cert"
          secret {
            secret_name = "ingress-nginx-admission"
          }
        }

        toleration {
          effect = "NoSchedule"
          key    = "node-role.kubernetes.io/master"
        }
        toleration {
          effect = "NoSchedule"
          key    = "node-role.kubernetes.io/control-plane"
        }
      }
    }
  }
}

resource "kubernetes_ingress_class_v1" "nginx" {
  metadata {
    name   = var.ingress_class_name
    labels = local.controller_labels
  }
  spec { controller = var.controller_class }
}
