resource "helm_release" "velero" {
  name             = "velero"
  namespace        = "velero"
  version          = var.velero.version
  repository       = "https://vmware-tanzu.github.io/helm-charts"
  chart            = "velero"
  values           = var.velero.values
  create_namespace = true
}

module "kube" {
  source     = "../modules/kubernetes-provider-conf"
  kubeconfig = var.kubeconfig
}

module "minio-provider" {
  source         = "../modules/minio-provider-conf"
  minio_key_file = var.minio_key_file
}
