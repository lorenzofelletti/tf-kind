terraform {
  required_version = "~> 1.9"

  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = "~> 2.4.0"
    }
  }

  backend "s3" {}
}

provider "kubernetes" {
  config_path            = module.kube.configuration.config_path
  config_context         = module.kube.configuration.context
  client_certificate     = module.kube.configuration.client_certificate
  client_key             = module.kube.configuration.client_key
  cluster_ca_certificate = module.kube.configuration.cluster_ca_certificate
  host                   = module.kube.configuration.host
}

provider "helm" {
  kubernetes {
    config_path            = module.kube.configuration.config_path
    config_context         = module.kube.configuration.context
    client_certificate     = module.kube.configuration.client_certificate
    client_key             = module.kube.configuration.client_key
    cluster_ca_certificate = module.kube.configuration.cluster_ca_certificate
    host                   = module.kube.configuration.host
  }
}

provider "minio" {
  minio_server   = var.minio_server
  minio_user     = module.minio-provider.configuration.access_key
  minio_password = module.minio-provider.configuration.secret_key
}
