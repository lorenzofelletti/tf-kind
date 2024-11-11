velero = {
  version     = "v7.2.2"
  values_file = "values.yaml"
}

### --- Terraform Configuration --- ###

kubeconfig = {
  remote = {
    bucket_name = "cluster-kubeconfig"
    object_name = "kubeconfig"
  }
}

minio_key_file = "./credentials.json"
