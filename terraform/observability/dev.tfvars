observability = {
  kube_prometheus_version = "61.2.0"
}

### --- Terraform Configuration --- ###

kubeconfig = {
  remote = {
    bucket_name = "cluster-kubeconfig"
    object_name = "kubeconfig"
  }
}

minio_key_file = "./credentials.json"
