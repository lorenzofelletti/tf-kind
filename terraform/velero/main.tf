resource "helm_release" "velero" {
  name             = "velero"
  namespace        = "velero"
  version          = var.velero.version
  repository       = "https://vmware-tanzu.github.io/helm-charts"
  chart            = "velero"
  values           = local.values
  create_namespace = false

  depends_on = [kubernetes_namespace_v1.velero, kubernetes_secret_v1.velero]
}

resource "kubernetes_namespace_v1" "velero" {
  metadata {
    name = "velero"
  }
}

resource "kubernetes_secret_v1" "velero" {
  metadata {
    name      = "velero-credentials"
    namespace = "velero"
  }
  type = "Opaque"
  data = {
    cloud = local.minio_secret_data
  }

  depends_on = [kubernetes_namespace_v1.velero]
}

resource "minio_s3_bucket" "velero_backups" {
  bucket        = var.bucket_name
  force_destroy = false
}

data "terraform_remote_state" "workloads" {
  backend = "s3"

  config = {
    access_key = module.minio-provider.configuration.access_key
    secret_key = module.minio-provider.configuration.secret_key

    endpoints = {
      s3 = var.workload_remote_state.endpoint
    }

    region                      = var.workload_remote_state.region
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true

    bucket = var.workload_remote_state.bucket
    key    = var.workload_remote_state.key
  }
}

### --- Terraform Configuration --- ###
data "terraform_remote_state" "cluster" {
  backend = "s3"

  config = {
    access_key = module.minio-provider.configuration.access_key
    secret_key = module.minio-provider.configuration.secret_key

    endpoints = {
      s3 = var.cluster_remote_state.endpoint
    }

    region                      = var.cluster_remote_state.region
    skip_credentials_validation = true
    skip_metadata_api_check     = true
    skip_region_validation      = true
    skip_requesting_account_id  = true
    use_path_style              = true

    bucket = var.cluster_remote_state.bucket
    key    = var.cluster_remote_state.key
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
