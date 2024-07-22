cluster_spec = {
  name        = "observability-test"
  k8s_version = "1.30.0"
  networking = {
    ip_family           = "ipv4"
    disable_default_cni = true
    install_calico      = true
    pod_subnet          = "192.168.0.0/16"
  }
  nodes = {
    "cp" = {
      role = "control-plane"
    },
    "w1" = {
      role = "worker"
    },
  }
}

expose_minio_in_cluster = {
  enabled = true
  network = "proxy"
}

calico_version = "v3.28.0"

kubeconfig_path = "~/.kube/kind-config"

minio_key_file                = "./credentials.json"
kubeconfig_upload_bucket_name = "cluster-kubeconfig"
