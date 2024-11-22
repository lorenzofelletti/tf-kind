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
  nginx_default_conf = file("${path.module}/nginx-minio.conf")
}

### --- Terraform Configuration --- ###

module "kube" {
  source     = "../modules/kubernetes-provider-conf"
  kubeconfig = var.kubeconfig
}

module "minio-provider" {
  source         = "../modules/minio-provider-conf"
  minio_key_file = var.minio_key_file
}
