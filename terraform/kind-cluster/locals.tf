locals {
  non_default_cluster_config_detected = (
    var.cluster_spec.containerd_config_patches != [] ||
    length(keys(var.cluster_spec.nodes)) > 0 ||
    var.cluster_spec.networking != null
  )

  ingress_kubeadm_patch = <<-EOT
  kind: InitConfiguration
  nodeRegistration:
    kubeletExtraArgs:
      node-labels: "ingress-ready=true"
  EOT

  minio_network_geteway = (
    var.expose_minio_in_cluster.enabled &&
    var.expose_minio_in_cluster.network != null
  ) ? data.docker_network.minio[0].ipam_config.*.gateway[0] : var.expose_minio_in_cluster.gateway

  kubeconfig_path = pathexpand(var.kubeconfig_path)
  kubeconfig      = kind_cluster.this.kubeconfig
  context_name    = "kind-${kind_cluster.this.name}"
}
