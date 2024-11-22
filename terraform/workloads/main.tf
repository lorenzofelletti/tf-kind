

module "kube" {
  source     = "../modules/kubernetes-provider-conf"
  kubeconfig = var.kubeconfig
}

module "minio-provider" {
  source         = "../modules/minio-provider-conf"
  minio_key_file = var.minio_key_file
}
