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
        container {
          name  = "expose-network"
          image = "qoomon/docker-host"
          security_context {
            capabilities {
              add = ["NET_ADMIN", "NET_RAW"]
            }
          }
          # env {
          #   name  = "DOCKER_HOST"
          #   value = var.network_gateway
          # }
          # env {
          #   name  = "PORTS"
          #   value = var.ports
          # }
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
  }
}

resource "kubernetes_service_v1" "external_name" {
  metadata {
    name      = "minio"
    namespace = "kube-system"
  }
  spec {
    type          = "ExternalName"
    external_name = "host.docker.internal"
  }
}
