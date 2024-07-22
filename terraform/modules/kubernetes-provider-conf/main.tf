data "minio_s3_object" "kubeconfig" {
  count = var.kubeconfig.remote != null ? 1 : 0

  object_name = var.kubeconfig.remote.object_name
  bucket_name = var.kubeconfig.remote.bucket_name
}

check "fetched_kubeconfig" {
  assert {
    condition = try((
      data.minio_s3_object.kubeconfig[0].content != null &&
      data.minio_s3_object.kubeconfig[0].content != ""),
      true
    )
    error_message = "Fetched kubeconfig is empty."
  }
}

check "decoded_remote_kubeconfig" {
  assert {
    condition = var.kubeconfig.local != null || (
      local.decoded_remote_kubeconfig != null &&
      local.decoded_remote_kubeconfig.contexts != null &&
      local.decoded_remote_kubeconfig.clusters != null &&
      local.decoded_remote_kubeconfig.users != null
    )
    error_message = "Problem decoding remote kubeconfig. Check it is a valid YAML file."
  }
}

check "kubeconfig" {
  assert {
    condition = var.kubeconfig.local != null || anytrue([
      local.kube_conf.client_certificate != null,
      local.kube_conf.client_key != null,
      local.kube_conf.cluster_ca_certificate != null,
      local.kube_conf.host != null
    ])
    error_message = "Problem unpacking remote kubeconfig data."
  }
}
