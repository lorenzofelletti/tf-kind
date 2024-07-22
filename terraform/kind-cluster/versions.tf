terraform {
  required_version = "~> 1.9"

  required_providers {
    kind = {
      source  = "tehcyx/kind"
      version = "~> 0.5.1"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
    minio = {
      source  = "aminueza/minio"
      version = "~> 2.4.0"
    }
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
  }

  backend "s3" {}
}

provider "docker" {}

provider "kind" {}

provider "kubernetes" {
  config_path = kind_cluster.this.kubeconfig_path
  # config_context = "kind-${kind_cluster.this.name}"
}

provider "minio" {
  minio_server   = var.minio_server
  minio_user     = module.minio-provider.configuration.access_key
  minio_password = module.minio-provider.configuration.secret_key
}
