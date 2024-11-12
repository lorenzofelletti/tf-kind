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

      containerd_config_patches = local.containerd_config_patches

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
  namespace_labels = var.expose_minio_in_cluster.namespace_labels

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

resource "terraform_data" "kind_registry" {
  count = var.deploy_local_registry ? 1 : 0

  triggers_replace = [
    sha256(kind_cluster.this.kubeconfig),
    var.deploy_local_registry,
    var.local_registry_spec.name,
    var.local_registry_spec.registry_port,
    var.local_registry_spec.registry_container_port,
  ]

  provisioner "local-exec" {
    interpreter = ["bash", "-c"]
    command     = <<-EOT
    set -o errexit
    reg_name=${var.local_registry_spec.name}
    reg_port=${var.local_registry_spec.registry_port}
    reg_container_port=${var.local_registry_spec.registry_container_port}

    REGISTRY_DIR="/etc/containerd/certs.d/localhost:$${reg_port}"
    for node in $(kind get nodes -n "${var.cluster_spec.name}"); do
      docker exec "$${node}" mkdir -p "$${REGISTRY_DIR}"
      cat <<EOF | docker exec -i "$${node}" cp /dev/stdin "$${REGISTRY_DIR}/hosts.toml"
    [host."http://$${reg_name}:$${reg_container_port}"]
    EOF
    done
    EOT
    when        = create
  }

  depends_on = [kind_cluster.this, docker_container.registry]
}

resource "docker_network" "registry" {
  count = var.deploy_local_registry ? 1 : 0

  name   = var.local_registry_spec.name
  driver = "bridge"
}

resource "docker_container" "registry" {
  count = var.deploy_local_registry ? 1 : 0

  name    = var.local_registry_spec.name
  image   = "registry:2"
  restart = "always"
  ports {
    internal = var.local_registry_spec.registry_container_port
    external = var.local_registry_spec.registry_port
  }
  network_mode = "bridge"
  networks_advanced {
    name = docker_network.registry[0].name
  }
  networks_advanced {
    name = "kind"
  }
  lifecycle {
    ignore_changes = [image]
  }
}

resource "kubernetes_config_map_v1" "document_registry" {
  count = var.deploy_local_registry ? 1 : 0

  metadata {
    name      = "local-registry-hosting"
    namespace = "kube-public"
  }

  data = {
    "localRegistryHosting.v1" = <<-EOT
    host: "localhost:${var.local_registry_spec.registry_port}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
    EOT
  }

  depends_on = [kind_cluster.this]
}

resource "terraform_data" "ingress-nginx" {
  count = var.cluster_spec.deploy_ingress_nginx ? 1 : 0

  provisioner "local-exec" {
    command = <<-EOT
    set -euo pipefail

    export KUBECONFIG=$KUBECONFIG
    kubectl config use-context $CONTEXT
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml

    kubectl wait --namespace ingress-nginx \
      --for=condition=ready pod \
      --selector=app.kubernetes.io/component=controller \
      --timeout=90s
    EOT

    environment = {
      "KUBECONFIG" = local.kubeconfig_path
      "CONTEXT"    = local.context_name
    }

    when       = create
    on_failure = continue
  }

  triggers_replace = sha256(kind_cluster.this.kubeconfig)
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
