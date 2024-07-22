resource "helm_release" "kube_prometheus" {
  name       = var.observability.kube_prometheus_name
  namespace  = kubernetes_namespace.monitoring.metadata[0].name
  version    = var.observability.kube_prometheus_version
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  values     = var.observability.values
}

resource "kubernetes_namespace" "monitoring" {
  metadata {
    name = var.observability.namespace
  }
}

module "kube" {
  source     = "../modules/kubernetes-provider-conf"
  kubeconfig = var.kubeconfig
}

module "minio-provider" {
  source         = "../modules/minio-provider-conf"
  minio_key_file = var.minio_key_file
}
