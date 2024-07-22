resource "kubernetes_deployment_v1" "network" {
  metadata {
    name      = local.name
    namespace = "kube-system"
    labels    = local.labels
  }
  spec {
    replicas = 1
    selector {
      match_labels = local.labels
    }
    template {
      metadata {
        name      = local.name
        namespace = "kube-system"
        labels    = local.labels
      }
      spec {
        host_network = true
        container {
          name  = "expose-network"
          image = "qoomon/docker-host"
          security_context {
            capabilities {
              add = ["NET_ADMIN", "NET_RAW"]
            }
          }

          dynamic "env" {
            for_each = var.network_gateway != null ? toset(["this"]) : toset([])
            content {
              name  = "DOCKER_HOST"
              value = var.network_gateway
            }
          }
          env {
            name  = "PORTS"
            value = var.ports
          }
          dynamic "port" {
            for_each = local.ports
            content {
              container_port = port.value
              host_port      = port.value
              protocol       = "TCP"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "network" {
  metadata {
    name      = local.name
    namespace = "kube-system"
  }
  spec {
    cluster_ip = "None"
    selector   = local.labels

    dynamic "port" {
      for_each = local.ports
      content {
        name        = "port-${port.key}"
        port        = port.value
        target_port = port.value
        protocol    = "TCP"
      }
    }
  }
}
