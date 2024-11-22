

### --- Terraform Configuration --- ###

kubeconfig = {
  remote = {
    bucket_name = "cluster-kubeconfig"
    object_name = "kubeconfig"
  }
}

minio_key_file = "./credentials.json"
