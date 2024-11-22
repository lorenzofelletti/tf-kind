terraform {
  required_providers {
    tls = {
      source  = "hashicorp/tls"
      version = "> 4.0.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "> 2.0.0"
    }
  }
}
