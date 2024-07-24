resource "kubernetes_deployment_v1" "network" {
  metadata {
    name      = local.name
    namespace = var.namespace
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
        namespace = var.namespace
        labels    = local.labels
      }
      spec {
        host_network = true
        container {
          name  = "expose-network"
          image = "nginx:latest"
          security_context {
            capabilities {
              add = ["NET_ADMIN", "NET_RAW"]
            }
          }
          dynamic "port" {
            for_each = local.ports
            content {
              container_port = port.value
              host_port      = port.value
              protocol       = "TCP"
            }
          }
          volume_mount {
            name       = "nginx-conf"
            mount_path = "/etc/nginx/conf.d"
          }
        }
        volume {
          name = "nginx-conf"
          config_map {
            name         = kubernetes_config_map_v1.nginx-config.metadata[0].name
            default_mode = "0644"
          }
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "network" {
  metadata {
    name      = local.name
    namespace = var.namespace
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

resource "kubernetes_config_map_v1" "nginx-config" {
  metadata {
    name      = "nginx-config"
    namespace = var.namespace
  }
  data = {
    "default.conf" = var.nginx_default_conf
  }
}
