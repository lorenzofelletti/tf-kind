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
          role  = node.value.role
          image = "kindest/node:v${var.cluster_spec.k8s_version}"
          kubeadm_config_patches = (node.value.ingress_ready ?
            [local.ingress_kubeadm_patch] :
            node.value.kubeadm_config_patches
          )

          dynamic "extra_port_mappings" {
            for_each = toset(node.value.extra_port_mappings)
            content {
              container_port = extra_port_mappings.value.container_port
              host_port      = extra_port_mappings.value.host_port
              listen_address = extra_port_mappings.value.listen_address
              protocol       = extra_port_mappings.value.protocol
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

module "expose-minio" {
  count  = var.expose_minio_in_cluster.enabled ? 1 : 0
  source = "../modules/expose-external"

  name             = "minio"
  namespace        = "minio"
  create_namespace = true

  ports              = "9000"
  nginx_default_conf = <<-EOT
  server {
    listen 9000;
    server_name host.docker.internal
    # Allow special characters in headers
    ignore_invalid_headers off;
    # Allow any size file to be uploaded.
    # Set to a value such as 1000m; to restrict file size to a specific value
    client_max_body_size 0;
    # Disable buffering
    proxy_buffering off;
    proxy_request_buffering off;

    location / {
      proxy_pass http://host.docker.internal:9000;
      proxy_set_header Host $http_host;
      #proxy_pass_request_headers off;
      #proxy_buffering off;
      chunked_transfer_encoding off;
      proxy_set_header X-Real-IP $remote_addr;
      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      proxy_set_header X-Forwarded-Proto $scheme;
    }
  }
  EOT

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
