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
