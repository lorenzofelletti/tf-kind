cluster_spec = {
  name        = "observability-test"
  k8s_version = "1.31.2"
  networking = {
    ip_family           = "ipv4"
    disable_default_cni = true
    install_calico      = true
    pod_subnet          = "192.168.0.0/16"
  }
  deploy_ingress_nginx = true
  nodes = {
    "cp" = {
      role          = "control-plane"
      ingress_ready = true
      extra_port_mappings = [
        {
          container_port = 80
          host_port      = 80
        },
        {
          container_port = 443
          host_port      = 443
        }
      ]
    },
    "w1" = {
      role = "worker"
    },
  }
}

deploy_local_registry = true
local_registry_spec = {
  add_cluster_containerd_config_patch = true
}

expose_minio_in_cluster = {
  enabled = true
  namespace_labels = {
    "restricted" = "true"
  }
}

pre_provisioned_self_signed_tls_certificates = {
  "local_io" = {
    secret_name      = "tls"
    secret_namespace = "vtest-cluster"
    dns_names        = ["*.local.io"]
    subject = {
      common_name  = "*.local.io"
      organization = "Local Kubernetes"
    }
  }
}

calico_version = "v3.28.0"

kubeconfig_path = "~/.kube/kind-config"

minio_key_file                = "./credentials.json"
kubeconfig_upload_bucket_name = "cluster-kubeconfig"
