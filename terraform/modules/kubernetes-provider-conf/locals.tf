locals {
  # local kubeconfig handling
  local_kubeconfig = {
    config_path = try(pathexpand(var.kubeconfig.local.path), null)
    # remote kubeconfig need this to be null
    context = var.kubeconfig.local != null ? var.kubeconfig.context_name : null
  }

  # remote kubeconfig handling
  decoded_remote_kubeconfig = sensitive(try(
    yamldecode(data.minio_s3_object.kubeconfig[0].content),
    null
  ))
  # cluster and user to look for in the kubeconfig file
  kubeconfig_ctx_idx = coalesce(var.kubeconfig.context_name, "0")
  remote_context_cluster_user = [for entry in try(local.decoded_remote_kubeconfig.contexts, [{}]) : {
    cluster = try(entry.context.cluster, null)
    user    = try(entry.context.user, null)
  } if try(entry.name == local.kubeconfig_ctx_idx || local.kubeconfig_ctx_idx == "0", true)][0]
  # unpack the cluster and user data from the kubeconfig file, leaving them as null if not found
  server_config = [for entry in try(local.decoded_remote_kubeconfig.clusters, [{}]) : {
    cluster_ca_certificate = try(base64decode(entry.cluster.certificate-authority-data), null)
    host                   = try(entry.cluster.server, null)
  } if try(entry.name == local.remote_context_cluster_user.cluster, true)][0]
  client_config = [for entry in try(local.decoded_remote_kubeconfig.users, [{}]) : {
    client_certificate = try(base64decode(entry.user.client-certificate-data), null)
    client_key         = try(base64decode(entry.user.client-key-data), null)
    exec               = try(entry.user.exec, null)
  } if try(entry.name == local.remote_context_cluster_user.user, true)][0]

  # value used to configure kubernetes and helm providers (both if kubeconfig is local or remote)
  kube_conf = merge(local.local_kubeconfig, local.server_config, local.client_config)
}
