resource "kind_cluster" "this" {
  name            = var.cluster_spec.name
  node_image      = "kindest/node:v${var.cluster_spec.k8s_version}"
  wait_for_ready  = var.cluster_spec.wait_for_ready
  kubeconfig_path = local.kubeconfig_path

  dynamic "kind_config" {
    for_each = local.non_default_cluster_config_detected ? toset(["this"]) : toset([])

    content {
      kind        = "Cluster"
      api_version = "kind.x-k8s.io/v1alpha4"

      containerd_config_patches = var.cluster_spec.containerd_config_patches

      dynamic "networking" {
        for_each = var.cluster_spec.networking != null ? toset(["this"]) : toset([])

        content {
          api_server_port     = var.cluster_spec.networking.apiserver_port
          disable_default_cni = var.cluster_spec.networking.disable_default_cni
          ip_family           = var.cluster_spec.networking.ip_family
          pod_subnet          = var.cluster_spec.networking.pod_subnet
          service_subnet      = var.cluster_spec.networking.service_subnet
        }
      }

      dynamic "node" {
        for_each = var.cluster_spec.nodes
        content {
          role                   = node.value.role
          image                  = "kindest/node:v${var.cluster_spec.k8s_version}"
          kubeadm_config_patches = node.value.kubeadm_config_patches
          dynamic "extra_port_mappings" {
            for_each = node.value.extra_port_mappings != null ? toset(["this"]) : toset([])
            content {
              container_port = node.value.extra_port_mappings.container_port
              host_port      = node.value.extra_port_mappings.host_port
              listen_address = node.value.extra_port_mappings.listen_address
              protocol       = node.value.extra_port_mappings.protocol
            }
          }
        }
      }
    }
  }

  lifecycle {
    precondition {
      condition     = var.calico_version == null || try(var.cluster_spec.networking.install_calico, false)
      error_message = "Calico version is specified but networking.install_calico is not set to `true`"
    }
  }
}

data "docker_network" "minio" {
  count = var.expose_minio_in_cluster.enabled && var.expose_minio_in_cluster.network != null ? 1 : 0
  name  = var.expose_minio_in_cluster.network
}

module "expose-minio-network" {
  count  = var.expose_minio_in_cluster.enabled ? 1 : 0
  source = "../modules/expose-network"

  network_name = "minio"
  ports        = "9000-9001"

  depends_on = [kind_cluster.this]
}

module "calico" {
  count  = var.calico_version != null ? 1 : 0
  source = "../modules/install-calico"

  kubeconfig_path    = local.kubeconfig_path
  kubeconfig_context = local.context_name
  calico_version     = var.calico_version

  additional_replace_trigger = [kind_cluster.this.kubeconfig]
}

module "upload_kubeconfig" {
  source = "../modules/upload-to-minio"
  count  = var.kubeconfig_upload_bucket_name != null ? 1 : 0

  bucket_name       = var.kubeconfig_upload_bucket_name
  create_bucket     = true
  object_name       = "kubeconfig"
  content_to_upload = kind_cluster.this.kubeconfig
}

module "minio-provider" {
  source         = "../modules/minio-provider-conf"
  minio_key_file = var.minio_key_file
}
